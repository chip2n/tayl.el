;;; tayl.el --- Tayl client for Emacs

;; Copyright (C) 2019 Andreas Arvidsson

;; Author: Andreas Arvidsson <andreas@arvidsson.io>
;; Keywords: tools
;; Version: 0.0.1
;; Package-Requires: ((request "0.3.0"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Code:

(require 'request)

(defvar tayl-api-token nil)

(defun tayl-send (url)
  (if (not tayl-api-token)
      (message "You need to specify an API token for Tayl first (using tayl-api-token).")
    (tayl--send-with-token url tayl-api-token)))

(defun tayl--send-with-token (url token)
  (message "Sending %S to Tayl..." url)
  (request
   "https://x.tayl.app/submit"
   :type "POST"
   :headers `(("ContentType" . "application/json")
              ("x-api-token" . ,token))
   :data `(("url" . ,url))
   :parser 'json-read
   :success (cl-function
             (lambda (&key data &allow-other-keys)
               (message "Success!")))
   :error (cl-function
           (lambda (&key error-thrown &allow-other-keys)
             (message "Error: %S" error-thrown)))
   :complete (lambda (&rest _)
               (message "Finished!"))))

(defun tayl-send-elfeed-feed ()
  (interactive)
  (let ((url (tayl--elfeed-get-url-of-current-feed)))
    (tayl-send url)))

(defun tayl--elfeed-get-url-of-current-feed ()
  (save-excursion
    (beginning-of-buffer)
    (re-search-forward "Link: " nil t)
    (elfeed-get-url-at-point)))

(provide 'tayl)

;;; tayl.el ends here
