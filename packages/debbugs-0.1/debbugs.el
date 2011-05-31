;;; debbugs.el --- SOAP library to access debbugs servers

;; Copyright (C) 2011 Free Software Foundation, Inc.

;; Author: Michael Albinus <michael.albinus@gmx.de>
;; Keywords: comm, hypermedia
;; Package: debbugs
;; Version: 0.1

;; This file is part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This package provides some basic functions to access a debbugs SOAP
;; server (see <http://wiki.debian.org/DebbugsSoapInterface>).

;; The SOAP functions "get_usertag" and "get_versions" are not
;; implemented (yet).

;;; Code:

;(setq soap-debug t message-log-max t)
(require 'soap-client)
(eval-when-compile (require 'cl))

(defcustom debbugs-port "gnu.org"
  "The port instance to be applied from `debbugs-wsdl'.
This corresponds to the Debbugs server to be accessed, either
\"gnu.org\", or \"debian.org\"."
  ;; Maybe we should create an own group?
  :group 'emacsbug
  :type '(choice :tag "Debbugs server" (const "gnu.org") (const "debian.org")))

;; It would be nice if we could retrieve it from the debbugs server.
;; Not supported yet.
(defconst debbugs-wsdl
  (soap-load-wsdl
   (expand-file-name
    "Debbugs.wsdl"
    (if load-in-progress
	(file-name-directory load-file-name)
      default-directory)))
  "The WSDL object to be used describing the SOAP interface.")

(defun debbugs-get-bugs (&rest query)
  "Return a list of bug numbers which match QUERY.

QUERY is a keyword value sequence, whereby the values are strings.
All queries are concatenated via AND.

Valid keywords are:

  :package -- The value is the name of the package a bug belongs
  to, like \"emacs\", \"coreutils\", \"gnus\", or \"tramp\".

  :severity -- This is the severity of the bug.  Currently,
  there exists the severities \"important\", \"grave\",
  \"normal\", \"minor\" and \"wishlist\".

  :tag -- An arbitrary string the bug is annotated with.
  Usually, this is used to mark the status of the bug, like
  \"fixed\", \"moreinfo\", \"notabug\", \"patch\",
  \"unreproducible\" or \"wontfix\".

  :owner -- This is used to identify bugs by the owner's email
  address.  The special email address \"me\" is used as pattern,
  replaced with `user-mail-address'.

  :submitter -- With this keyword it is possible to filter bugs
  by the submitter's email address.  The special email address
  \"me\" is used as pattern, replaced with `user-mail-address'.

  :archive -- A keyword to filter for bugs which are already
  archived, or not.  Valid values are \"0\" (not archived),
  \"1\" (archived) or \"both\".  If this keyword is not given in
  the query, `:archive \"0\"' is assumed by default.

Example:

  \(debbugs-get-bugs :submitter \"me\" :archive \"both\")
  => \(5516 5551 5645 7259)"

  (let (vec key val)
    ;; Check query.
    (while (and (consp query) (<= 2 (length query)))
      (setq key (pop query)
	    val (pop query)
	    vec (vconcat vec (list (substring (symbol-name key) 1))))
      (unless (and (keywordp key) (stringp val))
        (error "Wrong query: %s %s" key val))
      (case key
	((:package :severity :tag)
	 ;; Value shall be one word.
	 (if (string-match "\\`[A-Za-z]+\\'" val)
	     (setq vec (vconcat vec (list val)))
	   (error "Wrong %s: %s" (car (last vec)) val)))
	;; Value is an email address.
	((:owner :submitter)
	 (if (string-match "\\`\\S-+\\'" val)
	     (progn
	       (when (string-equal "me" val)
		 (setq val user-mail-address))
	       (when (string-match "<\\(.+\\)>" val)
		 (setq val (match-string 1 val)))
	       (setq vec (vconcat vec (list val))))
	   (error "Wrong %s: %s" (car (last vec)) val)))
	(:archive
	 ;; Value is `0' or `1' or `both'.
	 (if (string-match "\\`\\(0\\|1\\|both\\)\\'" val)
	     (setq vec (vconcat vec (list val)))
	   (error "Wrong %s: %s" (car (last vec)) val)))
	(t (error "Unknown key: %s" (car (last vec))))))

    (unless (null query)
      (error "Unknown key: %s" (car query)))

    (sort (car (soap-invoke debbugs-wsdl debbugs-port "get_bugs" vec)) '<)))

(defun debbugs-newest-bugs (amount)
  "Return the list of bug numbers, according to AMOUNT (a number) latest bugs."
  (sort (car (soap-invoke debbugs-wsdl debbugs-port "newest_bugs" amount)) '<))

(defun debbugs-get-status (&rest bug-numbers)
  "Return a list of status entries for the bugs identified by BUG-NUMBERS.

Every returned entry is an association list with the following attributes:

  `bug_num': The bug number.

  `package': A list of package names the bug belongs to.

  `severity': The severity of the bug report. This can be
  \"important\", \"grave\", \"normal\", \"minor\" or \"wishlist\".

  `tags': The status of the bug report, a list of strings.  This
  can be \"fixed\", \"notabug\", \"wontfix\", \"unreproducible\",
  \"moreinfo\" or \"patch\".

  `pending': The string \"pending\", \"forwarded\" or \"done\".

  `subject': Subject/Title of the bugreport.

  `originator': Submitter of the bugreport.

  `mergedwith': A list of bug numbers this bug was merged with.

  `source': Source package name of the bug report.

  `date': Date of bug creation.

  `log_modified', `last_modified': Date of last update.

  `found_date', `fixed_date': Date of bug report / bug fix
  \(empty for now).

  `done': The email address of the worker who has closed the bug (if done).

  `archived': `t' if the bug is archived, `nil' otherwise.

  `unarchived': The date the bug has been unarchived, if ever.

  `found_versions', `fixed_versions': List of version strings.

  `forwarded': A URL or an email address.

  `blocks': A list of bug numbers this bug blocks.

  `blockedby': A list of bug numbers this bug is blocked by.

  `msgid': The message id of the initial bug report.

  `owner': Who is responsible for fixing.

  `location': Always the string \"db-h\" or \"archive\".

  `affects': A list of package names.

  `summary': Arbitrary text.

Example:

  \(debbugs-get-status 10)

  => ;; Attributes with empty values are not show
     \(\(\(bug_num . 10)
       \(source . \"unknown\")
       \(date . 1203606305.0)
       \(msgid . \"<87zltuz7eh.fsf@freemail.hu>\")
       \(severity . \"wishlist\")
       \(owner . \"Magnus Henoch <mange@freemail.hu>\")
       \(log_modified . 1261079402.0)
       \(location . \"db-h\")
       \(subject . \"url-gw should support HTTP CONNECT proxies\")
       \(originator . \"Magnus Henoch <mange@freemail.hu>\")
       \(last_modified . 1271200046.0)
       \(pending . \"pending\")
       \(package \"emacs\")))"
  (let ((object
	 (car
	  (soap-invoke
	   debbugs-wsdl debbugs-port "get_status"
	   (apply 'vector bug-numbers)))))
    (mapcar
     (lambda (x)
       (let (y)
	 ;; "archived" is the number 1 or 0.
	 (setq y (assoc 'archived (cdr (assoc 'value x))))
	 (setcdr y (= (cdr y) 1))
	 ;; "found_versions" and "fixed_versions" are lists,
	 ;; containing strings or numbers.
	 (dolist (attribute '(found_versions fixed_versions))
	   (setq y (assoc attribute (cdr (assoc 'value x))))
	   (setcdr y (mapcar
		      (lambda (z) (if (numberp z) (number-to-string z) z))
		      (cdr y))))
	 ;; "mergedwith" is a string, containing blank separated bug numbers.
	 (setq y (assoc 'mergedwith (cdr (assoc 'value x))))
	 (when (stringp (cdr y))
	   (setcdr y (mapcar 'string-to-number (split-string (cdr y) " " t))))
	 ;; "package" is a string, containing comma separated package names.
	 ;; "keywords" and "tags" are strings, containing blank
	 ;; separated package names.
	 (dolist (attribute '(package keywords tags))
	   (setq y (assoc attribute (cdr (assoc 'value x))))
	   (when (stringp (cdr y))
	     (setcdr y (split-string (cdr y) ",\\| " t))))
	 (cdr (assoc 'value x))))
     object)))

(defun debbugs-get-bug-log (bug-number)
  "Return a list of messages related to BUG-NUMBER.

Every message is an association list with the following attributes:

  `msg_num': The number of the message inside the bug log.  The
  numbers are ascending, newer messages have a higher number.

  `header': The message header lines, as arrived at the bug tracker.

  `body': The message body.

  `attachments' A list of possible attachments, or `nil'.  Not
  implemented yet server side."
  (car (soap-invoke debbugs-wsdl debbugs-port "get_bug_log" bug-number)))

(defun debbugs-get-attribute (bug-or-message attribute)
  "Return the value of key ATTRIBUTE.

BUG-OR-MESSAGE must be list element returned by either
`debbugs-get-status' or `debbugs-get-bug-log'.

Example: Return the originator of last submitted bug.

\(debbugs-get-attribute
  \(car \(apply 'debbugs-get-status \(debbugs-newest-bugs 1))) 'originator)"
  (cdr (assoc attribute bug-or-message)))

(defun debbugs-get-message-numbers (messages)
  "Return the message numbers of MESSAGES.
MESSAGES must be the result of a `debbugs-get-bug-log' call."
  (mapcar (lambda (x) (debbugs-get-attribute x 'msg_num)) messages))

(defun debbugs-get-message (messages message-number)
  "Return the message MESSAGE-NUMBER of MESSAGES.
MESSAGES must be the result of a `debbugs-get-bug-log' call.

The returned message is a list of strings.  The first element are
the header lines of the message, the second element is the body
of the message.  Further elements of the list, if any, are
attachments of the message.

If there is no message with MESSAGE-NUMBER, the function returns `nil'.

Example: Return the first message of last submitted bug.

\(let \(\(messages \(apply 'debbugs-get-bug-log \(debbugs-newest-bugs 1))))
  \(debbugs-get-message messages
		       \(car \(debbugs-get-message-numbers messages))))"
  (while (and messages
	      (/= (debbugs-get-attribute (car messages) 'msg_num)
		  message-number))
    (setq messages (cdr messages)))
  (when messages
    (append (list (debbugs-get-attribute (car messages) 'header)
		  (debbugs-get-attribute (car messages) 'body))
	    (debbugs-get-attribute (car messages) 'attachments))))


(provide 'debbugs)

;;; TODO:

;; * SOAP interface extensions (wishlist).
;;   - Server-side sorting.
;;   - Regexp and/or wildcards search.
;;   - Fulltext search.
;;   - Returning message attachments.
;; * Widget-oriented bug overview like webDDTs.
;; * Actions on bugs.
;; * Integration into gnus (nnir).

;;; debbugs.el ends here