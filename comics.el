;; comics.el --- download and read comics from emacs
;;
;; Copyright (C) 2000,2004,2006,2009 Jay Belanger
;; $Date: 2007/02/18 00:14:45 $
;; $Revision: 1.75 $
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, you can either send email to this
;; program's maintainer or write to: The Free Software Foundation,
;; Inc.; 59 Temple Place, Suite 330; Boston, MA 02111-1307, USA.
;;
;;; Commentary:
;;
;; QUICK INTRO:
;; ============
;;
;; This package should work for Emacs versions 21.1 and up.
;;
;; comics.el provides a way to view and store comics that are available
;; on the web.  A list of favorite comics can be kept.
;;
;; To simply read a comic:
;; M-x comics-read-comic
;;     You will be prompted for a comic to read (with tab completion).
;;     With a numeric argument, the comic will be from that many days ago.
;;     With a non-numeric argument (such as C-u M-x comics-read-comic), you will
;;     be prompted for a date (in the form YYYYMMDD).
;;     In the buffer displaying the comic, the following commands are
;;     available:
;;
;; To get a list of all available comics:
;; M-x comics-list-comics
;;     You will be given a buffer with the categories of the available
;;     comics.  (Currently the categories are just the letters that the
;;     comics start with.)  Comics that have been chosen as favorites
;;     will be in bold.  The following commands will allow you to 
;;     sort through the categories:
;;     TAB     will toggle the display of the comics in the current category.
;;     C-cC-e  will expand all the categories (display all the comics)
;;     C-cC-h  will hide all the categories.
;;
;; Favorite comics:
;; Favorite comics can be read separately, and information about them
;; can be kept.  comics.el will keep track of which dates the favorites
;; comics have been read (starting with the date they were entered as
;; favorites).
;; To get a list of comics that have been chosen as favorites:
;; M-x comics-favorites-list-comics
;;     By default, the comics will be in alphabetical order.
;;     If the customizable variable `comics-favorites-alphabetical' is
;;     nil, then they won't necessarily be in order.  The order can then
;;     be adjusted with the following commands:
;;     C-cC-a  will put the comics in alphabetical order.
;;     C-k     will kill the current comic from the favorite comics list.
;;     C-y     will yank a killed comic to the favorites comics list.
;;
;; Bookmarks:
;; Bookmarks are a way of keeping track of particular comics.
;; Each comic can have a (default) bookmark, to make it easy to return 
;; to a particular date.  Comics can have more than one bookmark, by 
;; giving them names. (The default bookmark corresponds to the name "".)
;; There are global bookmarks, which aren't attached to any comic, but 
;; contain the comic information inside.  There is also a default global bookmark.
;;
;; Commands:
;; The following commands are available (as appropriate) in all comics
;; related buffers (the buffers displaying the comics as well as the buffers
;; with the lists of comics).  The "current comic" is the comic being viewed
;; or the comic on the current line.
;;  d        View the comic from a prompted-for date
;;  D        Download the comic from a prompted-for date
;;  g        View the comic at the default bookmark
;;           With an argument, prompt for a bookmark name
;;  G        View the comic at the default global bookmark
;;           With an argument, prompt for a bookmark name
;;  C-cC-b   Delete a bookmark
;;  C-cC-g   Delete a global bookmark
;;  f        Add the current comic to the favorites list.
;;           With an argument, prompt for a percent to resize the comic
;;           when it is displayed.  (A "t" here will have the comic
;;           resized to fill the buffer when opened.)
;;  C        Tell comics that all dates of all favorite comics have been read.
;;  l        Switch to a buffer containing the list of favorite
;;           comics.  Create one if necessary.
;;  C-cC-f   Download all the current favorite comics.
;;  C-cC-u   Download all the unread favorite comics.
;;  L        Switch to a buffer containing the list of available
;;           comics.  Create one if necessary.
;;  q        Bury the comic related buffers.
;;  k        Kill all the comics buffers
;;  K        Kill all the comic related buffers (comics and comic lists)
;;
;; When the current comic is a favorite, the following are also available:
;;  c        Tell comics that all dates of the current comic have been read.
;;  C-cC-r   Change the default resizing information for the current comic.
;;  C-cC-k   Remove the current comic from the favorites list.
;;
;; The following commands are available in the buffer displaying a comic:
;;  n        View the comic from the next day
;;           (with argument N, view the comic from N days forward)
;;  N        View the comic from the next day, skipping missing days
;;  p        View the comic from the previous day
;;           (with argument N, view the comic from P days previous)
;;  P        View the comic from the previous day, skipping missing days
;;  b        Set this comic as the default bookmark
;;           With an argument (C-u b), prompt for a name for
;;           the bookmark
;;  B        Set this comic as the default global bookmark
;;           With an argument (C-u b), prompt for a name for
;;           the bookmark
;;  DEL      Delete the comic file
;;  SPC      Read the next unread date (if the current comic is a favorite)
;;  u        Copy the URL of the comic to the kill ring.
;;  i        Copy the information (title, author, date) of the
;;           comic to the kill ring.
;;  U        Copy the URL and info to the kill ring.
;;  D        Copy (Duplicate) the comic file to a prompted-for file.
;;  C-cC-v   View the comic in an external viewer
;; If the variable `comics-buffer-resize' is non-nil and "convert"
;; from the ImageMagick(TM) utilities is installed, then the following 
;; commands are also available.
;;  F        Fit the comic to fill the buffer
;;  R        Resize the comic to a percentage of its current size
;;           (The percentage can be given as a prefix, or it will
;;           be prompted for.)
;;  O        Restore the comic to its original size.
;; This has been tested with version 6.2.6 of the ImageMagick(TM) 
;; utilities; it may work with some older versions.
;; ImageMagick(TM) is free software which is available at
;; http://www.imagemagick.org/
;;
;; The following commands are available in the buffers containing lists
;; of comics:
;;  r or RET  Read the comic on the current line.
;;            With a numeric argument, the comic will be from that many
;;            days before.
;;            With a non-numeric argument (such as C-u M-x comics-read-comic), 
;;            you will be prompted for a date (in the form YYYYMMDD).
;;            If the point is on a category line, toggle the display of
;;            the comics in the category.
;;  R or F    Like "r", but only downloads the comic (it doesn't display it).
;;  C-cC-d    Download the current comic and as many back strips as possible.
;;            With argument N, download N comics.
;;
;; 
;; NOTE:  The list `comics-list' is used for completion and getting 
;;        information for downloading the comics.  It is defined
;;        using the initial value of `comics-categorized-list'.
;;        If `comics-categorized-list' is changed after "comics"
;;        is loaded, `comics-list' won't match `comics-categorized-list'.
;;        If `comics-categorized-list' is made smaller, this isn't a
;;        problem, but if new comics are added to `comics-categorized-list'
;;        after "comics" is loaded, the function `comics-update-comics-list'
;;        should be run.
;;
;; To you these commands, it may be useful to put
;;  (autoload 'comics-read-comic "comics" "Read a comic." t)
;;  (autoload 'comics-favorites-list-comics "comics"
;;            "Go to a list of favorite comics." t)
;; in your .emacs
;;
;;Customizable variables:
;;  Storing:
;;  comics-dir (default: "~/Comics/")
;;              This is the directory to store the comics.
;;  comics-favorites-file (default: "~/.comics-favorites")
;;              A file to keep a list of the favorite comics in.
;;  comics-bookmark-file (default: "~/.comics-bookmarks")
;;              A file to keep the comics bookmarks in.
;;  comics-save-urls (default: t)
;;              Non-nil means store the urls of the downloaded comics.
;;  comics-url-file (default: (concat comics-dir "/comics-urls"))
;;              A file to keep the comics urls in.
;;  comics-filename-long-date (default: t)
;;              If non-nil, use (e.g.) 2004_August_1 as the date in 
;;              the filenames, otherwise use 2004_08_01.
;;  comics-use-separate-comic-directories (default: nil)
;;              If non-nil, use separate directories for the separate 
;;              comics.
;;  comics-temp-dir (default: "/tmp/")
;;              The directory for temporary files.
;;
;;  Viewing:
;;  comics-buffer-resize (default: t)
;;              If non-nil, enable commands to resize comics.
;;  comics-buffer-resize-on-open (default: nil)
;;              If t, open comics at a size to fill the buffer.
;;              If a number, open comics at that percent of the original size.
;;              If nil, open comics at original size.
;;  comics-view-comics-with-external-viewer (default: nil)
;;              If non-nil, use an external viewer to view comics.
;;  comics-external-viewer (default: "display")
;;              The external viewer to view the comics with.
;;  comics-external-viewer-args (default: nil)
;;              The arguments to pass to the external viewer.
;;
;;  Lists:
;;  comics-print-list-instructions (default: nil)
;;              If non-nil, print the instructions at the top 
;;              when creating a comics list.
;;  comics-favorites-alphabetical (default: t)
;;              If non-nil, keep favorite comics in alphabetical order.
;;
;;  Misc:
;;  comics-fetch-misses-allowed (default: 3)
;;              The number of times fetch back can fail to fetch a 
;;              comic before it gives up.
;;  comics-adjust-current-time (default: t)
;;              How to adjust today's date when computing today.
;;              If t, then today's date will be computed by looking at 
;;              the time zone of the web site.  
;;              If a number, it will be number of hours to adjust today's 
;;              day by when computing today; comics will regard today as 
;;              your computer time + `comics-adjust-current-time' hours.
;;              If nil, then today's date will the date where you are.
;;  comics-use-ido-completion (default: nil)
;;              If non-nil and `ido' is available, use `ido' for comic name 
;;              completions.
;;
;; A list of useful commands:
;; M-x comics-read-comic
;;     Read a prompted-for comic.
;;     With a numeric argument, the comic will be from that many days ago.
;;     With a non-numeric argument (such as C-u M-x comics-read-comic), you will
;;     be prompted for a date (in the form YYYYMMDD).
;; M-x comics-fetch-comic
;;     Download a prompted-for comic.
;;     With a numeric argument, the comic will be from that many days ago.
;;     With a non-numeric argument (such as C-u M-x comics-read-comic), you will
;;     be prompted for a date (in the form YYYYMMDD).
;; M-x comics-add-favorite
;;     Prompt for a comic to add to the favorite comics list.
;;     With an argument, prompt for a percent to resize the comic
;;     when it is displayed.  (A "t" here will have the comic
;;     resized to fill the buffer when opened.)
;;     (If the customizable variable `comics-get-storage-info' is
;;      non-nil, then this will also prompt for information on how
;;      to store the comic.  Entering a "D" will put the comic
;;      in a separate subdirectory, otherwise it will be stored in the
;;      default comics directory, and "L" will save the comic with
;;      the date written out, otherwise the comics will be saved with
;;      the date in numeric form.  These can be combined.  Entering
;;      a "t" will use the default storage method, which is customizable.)
;; M-x comics-remove-favorite
;;     Prompt for a comic to remove from the favorite comics list.
;; M-x comics-kill-comics-buffers
;;     Kill all the buffers used for viewing comics.
;; M-x comics-list-comics
;;     You will be given a buffer with the categories of the available
;;     comics.
;; M-x comics-favorites-list-comics
;;     You will be given a buffer with a list of all the favorite comics.
;; M-x comics-fetch-favorite-comics
;;     This will download a copy of the comics listed in the favorite
;;     comics list.
;; M-x comics-fetch-this-comic-back
;;     This will prompt you for a comic, then retrieve the current strip
;;     and as many older strips as it can.  The variable
;;     `comics-fetch-misses-allowed' will determine how many days in
;;     a row comics can fail to fetch a comic before it decides it's done.
;;     With arg N, fetch comics that many days back.
;; M-x comics-fetch-favorite-comics-back
;;     This will retrieve the current favorite comics and as many older 
;;     strips as it can.  With arg N, fetch comics that many days back.
;; M-x comics-goto-bookmark
;;     This will prompt you for a comic and will display the comic at the
;;     default bookmark.  With an argument, you will also be prompted for
;;     a bookmark name.
;; M-x comics-goto-global-bookmark
;;     This will display the comic at the global default bookmark.
;;     With an argument, you will be prompted for a bookmark name.
;; M-x comics-delete-bookmark
;;     This will prompt you for a comic and a bookmark, and will
;;     delete the bookmark
;; M-x comics-delete-global-bookmark
;;     This will prompt you for a bookmark, and will delete the 
;;     global bookmark
;;
;; NOTE:  If any of these comics are no longer available, or if there
;;        are ideas for more comics, please let me know so I can
;;        keep the list up-to-date.
;;        Please let me know of any other suggestions, bugs, comments,...
;;        belanger@truman.edu
;;
;; ANOTHER NOTE:  With the addition of the ability to keep track of dates on which the
;;        favorites have been read, the format of the comics-favorites list has 
;;        changed slightly.  If you didn't have storage information in the 
;;        comics-favorites list and simply had the comic names, the difference
;;        won't matter, otherwise you might wish to edit .comics-favorites and
;;        change entries like ("Comic Name" "D") to ("Comic Name" nil nil "D").
;;
;; CHANGES:
;;
;; 3 April 2010
;;
;; Fix `run-hooks' problem.
;; (Patch by Wesley Dawson.)
;;
;; 17 January 2010
;; 
;; Fixed problem retrieving comics.com comics.
;;
;; 24 August 2009
;;
;; Added a variable, `comics-show-title', which if non-nil will cause the
;; comic title and author to appear in the comic buffer.  By default it
;; is nil. (Patch by Dave Täht)
;;
;; 20 August 2009
;;
;; Added "Girl Genius"  (Thanks to Dave Täht)
;;
;; 23 Feb 2009
;;
;; Fixed bug in `comics-favorites-catch-up-comic'
;;
;; 11 Feb 2009
;;
;; Fixed Piled Higher and Deeper.
;; (Patch by Dr. Reimar Finken)
;;
;; 7 Feb 2009
;;
;; Fixed kingfeatures comics.
;;
;; 12 Jan 2009
;; Fixed comics.com comics, dilbert.
;;
;; 17 Feb 2007
;; Fix a problem downloading Xkcd.
;;
;; Add "D" binding to comics-buffer, which will copy the file for the current 
;; comic.
;;
;; Increase `comics-fetch-misses-allowed' to 7
;; If date of favorite comic being read is earlier than the earliest date,
;; don't add it to the dates-read list.
;; Add ShortPacked and Zippy.
;; Add "N" and "P" keybindings for comics buffers, which will read the next 
;; or previous comic, but skip any dates in which the comic cannot be obtained.  
;; (The most days skipped will be `comics-fetch-misses-allowed'.
;;
;; Some keybinding changes.
;; Remove fetch-only buffers.
;;
;; Now keeps track of which days the favorite comics have been read.
;; Resizing information can be kept on a per-comic basis.
;; (Suggested by Andy Scott.)
;;
;; Added the customizable variable `comics-buffer-resize-on-open'.
;; If t, this will cause the comic to fill the buffer when open.
;; If a number, this will cause the comic to be resized by that
;; percentage when opened.
;;
;; Add a "c" binding to calendar that will prompt for a comic 
;; to display.
;;
;; SPC will sequence through the unread favorite comics.
;; (Suggested by Andy Scott.)
;; If your favorites list contains extra storage information, such
;; as ("Comic Name" "D"), then that needs to be changed to
;; ("Comic Name" nil "D").  If you never put extra storage 
;; information in, then you don't need to worry about this.
;;
;; Use `comics-bury-comic-related-buffers' to bury buffers.
;;
;; Add bindings "k" and "K" to all comic related buffers.  These
;; will kill all comic/comic related buffers.
;;
;; Add bindings "l" and "L" to comics buffer, to go to the list of
;; favorite or all comics, respectively.
;; Add bindings "u" and "i", to copy URL and information, respectively,
;; of comic to kill ring.
;; Suggested by Andy Scott.
;;
;; Change resizing keys "f" and "r" to "F" and "R" in comics buffer.
;; Use "f" and "r" for adding and removing from favorites list.
;; Use `ido' completion when available.
;; Many other fixes and improvements.
;; Suggested by Andy Scott.
;;
;; Changed `comics-select-list' to `comics-favorites-list' and changed
;; the format.  This is no longer customizable, instead commands
;; are made to add or remove comics from the list.
;; Also, a buffer list for the favorite comics was added.  (See the
;; intro above.)
;;
;; More fixes and cleanups due to Detlev Zundel.
;;
;; Made modes for the comics buffer and the comics list buffers.
;; Information on the keybindings can now be gotten with 
;; C-hm (describe mode).  "h" and "?" in the comics-buffer now
;; calls describe-mode.
;; (Suggested by Detlev Zundel.)
;;
;; Added some interactive help in the browsing mode.
;; (Due to Detlev Zundel)
;; In the comics-buffer, "h" and "?" will give a list of available keys.
;;
;; Added comics-kill-comics-buffers
;;
;; Added a simple test to check if a downloaded Snoopy comic is really
;; a comic.
;;
;; Added a simple test to make sure the downloaded file is an image.
;;
;; Added Snoopy from Japan.
;;
;; Added some messages for fetching comics.
;;
;; Added the customizable variables 
;;  comics-filename-long-date
;;       If non-nil, use the `2004_August_01' form of the date in file
;;       names, otherwise use `2004_08_01'.  (The latter form will 
;;       the calender order the same as alphabetical order.)
;;  comics-use-separate-comic-directories
;;       If non-nil, each comic strip series will have its own 
;;       subdirectory of `comics-dir', otherwise all comics are
;;       in the same directory.
;;
;; Some bug fixes.
;;
;; Added the customizable variable:
;;  comics-adjust-current-time:
;;      This determines what date to use when trying to fetch a
;;      current comic.  If this variable is `t', then comics.el
;;      uses the current date at the website (based on a guess 
;;      of which time zone it is in).  If this variable is a number,
;;      that number of hours will be added to the current time 
;;      and that date will be used.  (So if you think the websites 
;;      are a couple of time zones away, you could set this to 2...)
;;      If this variable is nil, simply find the current date where you
;;      are at.
;;      This is an attempt to deal with the problem of looking for
;;      current comics when, because of time zone differences, it is
;;      a different day at your computer and the web site, so you wouldn't
;;      be able to download the "current" comic.
;;      It only applies when you are trying to get only a current comic,
;;      (comics-read-comic, comics-fetch-comic, comics-fetch-all-comics,
;;      comics-fetch-some-comics), and if the functions are given an 
;;      argument of "-" (C-u - M-x comics-read-comic), then there will be
;;      no attempts to adjust the time.
;;      I couldn't test this out very well, so if there are any problems
;;      with it, please let me know immediately so I can fix it.
;;      Thanks
;;
;; Added global bookmarks.
;; (Note that some bookmark bindings were changed)
;;
;; Added bookmarks.
;;
;; Added some resizing commands
;;
;; Added some new keys to the comic buffer keymap
;;
;; Added a face for the comics categories.
;; Changed how faces were applied.
;;
;; Created different faces for various parts of the buffer.
;; (Comic titles, dates, instructions, ...)
;; Added some keys to help move around in the list buffers.
;;
;; Fixed a few keymap problems.
;; Then, created distinct keymaps for the different buffers that
;; are created.  

(require 'calendar)

;;; Code:
(defgroup comics nil
  "Comics"
  :prefix "comics-"
  :tag    "Comics"
  :group  'applications)

(defcustom comics-dir "~/Comics/"
  "This is the directory to store the comics."
  :group 'comics
  :type 'directory)

(defcustom comics-save-in-dir nil
  "This is the default directory to copy the comic files to."
  :group 'comics
  :type '(choice (const :tag "Default" nil)
                 (directory)))

(defcustom comics-view-comics-with-external-viewer nil
  "If non-nil, use an external viewer to view comics."
  :group 'comics
  :type 'string)

(defcustom comics-external-viewer "display"
  "The external viewer to view the comics with."
  :group 'comics
  :type 'string)

(defcustom comics-external-viewer-args nil
  "The arguments to pass to the external viewer."
  :group 'comics
  :type 'string)

(defcustom comics-print-list-instructions nil
  "If non-nil, print the instructions at the top when creating a comics list."
  :group 'comics
  :type 'boolean)

(defcustom comics-buffer-resize t
  "If non-nil, enable commands to resize comics."
  :group 'comics
  :type 'boolean)

(defcustom comics-buffer-resize-on-open nil
  "If t, open comics at a size to fill the buffer.
If a number, open comics at that percent of the original size.
If nil, open comics at original size.
A non-nil value will slow the opening of the comic due to the
running of the convert program."
  :group 'comics
  :type '(choice (integer) (boolean)))

(defcustom comics-favorites-alphabetical t
  "If non-nil, keep favorite comics in alphabetical order."
  :group 'comics
  :type 'boolean)

(defcustom comics-get-storage-info nil
  "If non-nil, prompt for information on how to store favorite comics."
  :group 'comics
  :type 'boolean)

(defcustom comics-fetch-misses-allowed 7
  "The number of times fetch back can fail to fetch a comic before it gives up."
  :group 'comics
  :type 'integer)

(defcustom comics-temp-dir "/tmp/"
  "The directory for temporary files."
  :group 'comics
  :type 'directory)

(defcustom comics-bookmark-file "~/.comics-bookmarks"
  "A file to keep the comics bookmarks in."
  :group 'comics
  :type 'file)

(defcustom comics-favorites-file "~/.comics-favorites"
  "A file to keep a list of the favorite comics in."
  :group 'comics
  :type 'file)

(defcustom comics-save-urls t
  "Non-nil means store the urls of the downloaded comics."
  :group 'comics
  :type 'boolean)

(defcustom comics-url-file 
  (concat comics-dir "/comics-urls")
  "A file to keep the comics urls in."
  :group 'comics
  :type 'file)

(defcustom comics-filename-long-date t
  "If non-nil, use (e.g.) 2004_August_1 as the date in the filenames.
Otherwise use 2004_08_01."
  :group 'comics
  :type 'boolean)

(defcustom comics-use-separate-comic-directories nil
  "If non-nil, use separate directories for the separate comics."
  :group 'comics
  :type 'boolean)

(defcustom comics-adjust-current-time t
  "How to adjust today's date when computing today.
If t, then today's date will be computed by looking at the time zone
of the web site.  
If a number, it will be number of hours to adjust today's day by when 
computing today; comics will regard today as your computer time + 
`comics-adjust-current-time' hours.
If nil, then today's date will the date where you are."
  :group 'comics
  :type 'boolean)

(defcustom comics-use-ido-completion nil
  "If non-nil and `ido' is available, use `ido' for comic name completions."
  :group 'comics
  :type 'boolean)

(defcustom comics-show-titles nil
  "If non-nil display the text titles in the buffer"
  :group 'comics
  :type 'boolean)

(defvar comics-bookmarks '()
  "The comics bookmarks.")

(defvar comics-favorites-list '()
  "A list of comic names that can be downloaded as a group.")

(defvar comics-urls '()
  "The comics urls.")

(defvar comics-convert-program "convert"
  "The convert program from ImageMagick.")

(defvar comics-buffer-list '()
  "The list of buffers used to read comics.")

(defvar comics-favorites-kill-list nil
  "The list of comics that have been killed from the favorites buffer.")

(defface comics-list-current-face
  '((((background dark))
     (:foreground "LightSkyBlue"
      :weight bold
      :box t))
    (t
     (:foreground "blue"
      :weight bold
      :box t)))
  "The face to display the current line in a comics list buffer."
  :group 'comics)

(defface comics-list-prelude-face
  '((t
     :weight bold))
  "The face to display the prelude in a comics list buffer."
  :group 'comics)

(defface comics-list-instructions-face
  '((t
     :slant italic))
  "The face to display the instructions in the comics list buffer."
  :group 'comics)


(defface comics-list-category-face
  '((t
     :slant italic
     :weight bold))
  "The face to display the categories in the comics list buffer."
  :group 'comics)

(defface comics-date-face
  '((t
     :slant italic))
  "The face to display the date in the comics buffer."
  :group 'comics)

(defface comics-name-face
  '((t
     :weight bold))
  "The face to display the comic name in the comics buffer."
  :group 'comics)

(defface comics-favorites-face
  '((t
     :weight bold))
  "The face to display the favorite comics in the comics buffer."
  :group 'comics)

(defvar comics-wget-program "wget"
  "A program to get the comics.
It is expected to behave like `wget'.")

(defvar comics-latest-url nil)

(defvar comics-buffer-this-comic)
(make-variable-buffer-local 'comics-buffer-this-comic)
(defvar comics-buffer-comic-name)
(make-variable-buffer-local 'comics-buffer-comic-name)
(defvar comics-buffer-comic-date)
(make-variable-buffer-local 'comics-buffer-comic-date)
(defvar comics-buffer-comic-url)
(make-variable-buffer-local 'comics-buffer-comic-url)
(defvar comics-list-beg-point)
(make-variable-buffer-local 'comics-list-beg-point)

(defvar comics-list-buffer-name "*Comics*"
  "The name of the buffer for a Comics list.")

(defvar comics-favorites-list-buffer-name "*Comic favorites*"
  "The name of the buffer for a favorite comics list.")

(defvar comics-buffer-hook nil)
(defvar comics-list-comics-hook nil)
(defvar comics-favorites-list-comics-hook nil)

(defvar comics-categorized-list 
 '(("0-9"
    (".blue" "Julien Tromeur"
     "dotblue"
     comics-get-ucomics-dot-com-latest "dotblue" "blue")
    ("9 Chickweed Lane" "Brooke McEldowney"
     "9_Chickweed_Lane"
     comics-get-comics-dot-com "chickweed" "comics")
    ("9 to 5" "Harley Schwadron"
     "9_to_5"
     comics-get-ucomics-dot-com "tmntf" "gif"))
   ("A"
    ("adam's rust" "Adam Rust"
     "Adams_rust"
     comics-get-comicssherpa-dot-com-latest "cslbx")
    ("Agnes" "Tony Cochran"
     "Agnes"
     comics-get-comics-dot-com "agnes" "creators")
    ("Alley Oop"  "Jack and Carole Bender"
     "Alley_Oop"
     comics-get-comics-dot-com "alleyoop" "comics")
    ("Among Wolves" "Joseph Ward"
     "Among_Wolves"
     comics-get-comicssherpa-dot-com-latest "csvpk")
    ("Andy Capp"  "Reg Smythe"
     "Andy_Capp"
     comics-get-comics-dot-com "andycapp" "creators")
    ("Andy's Town & Planet" "Andy Menconi"
     "Andys_Town_and_Planet"
     comics-get-comicssherpa-dot-com-latest "cssuu")
    ("Animal Crackers" "Fred Wagner"
     "Animal_Crackers"
     comics-get-ucomics-dot-com "tmani" "gif")
    ("Annie" "Jay Maeder and Alan Kupperberg"
     "Annie"
     comics-get-ucomics-dot-com "tmann" "gif")
    ("Another Editorial Cartoon" "Some Guy"
     "Another_Editorial_Cartoon"
     comics-get-comicssherpa-dot-com-latest "csqjy")
;    ("Area 52" "Bob Darvas"
;     "Area_52"
;     comics-get-comicssherpa-dot-com-latest "cspgc")
    ("Arlo & Janis"  "Jimmy Johnson"
     "Arlo_and_Janis"
     comics-get-comics-dot-com "arlo&janis" "comics")
    ("Assisted Living" "Steve Crider"
     "Assisted_Living"
     comics-get-comicssherpa-dot-com-latest "cshsf")
    ("Attorney at Large" "Castagnera and Roberg"
     "Attorney_at_Large"
     comics-get-comicssherpa-dot-com-latest "csrjk"))
   ("B"
    ("B.C." "Johnny Hart"
     "BC"
     comics-get-comics-dot-com "bc" "creators")
    ("Bad Speller" "Tim Peckham"
     "Bad_Speller"
     comics-get-comicssherpa-dot-com-latest "csqme")
    ("Baldo" "Hector D. Cantu and Carlos Castellanos"
     "Baldo"
     comics-get-ucomics-dot-com "ba" "gif")
    ("Ballads of Uncle Bam" "Gus St. Anthony"
     "Ballads_of_Uncle_Bam"
     comics-get-comicssherpa-dot-com-latest "csmlf")
    ("Ballard Street"  "Jerry Van Amerongen"
     "Ballard_Street"
     comics-get-comics-dot-com "ballardst" "creators")
    ("Barkeater Lake" "Corey Pandolph"
     "Barkeater_Lake"
     comics-get-comics-dot-com "barkeaterlake" "comics")
    ("basketcase" "Kelly Ferguson"
     "Basketcase"
     comics-get-comicssherpa-dot-com-latest "csuvs")
    ("Battle Bug's Brigade" "Steven Bove"
     "Battle_Bugs_Brigade"
     comics-get-comicssherpa-dot-com-latest "csksb")
    ("Behind Door #3" "DeCourcey"
     "Behind_Door_3"
     comics-get-comicssherpa-dot-com-latest "csepb")
    ("Ben" "Daniel Shelton"
     "Ben"
     comics-get-comics-dot-com "ben" "comics")
    ("Benny & Floyd" "Tracy Nichols"
     "Benny_and_Floyd"
     comics-get-comicssherpa-dot-com-latest "csblf")
    ("Betty"  "Delainey and Rasmussen"
     "Betty"
     comics-get-comics-dot-com "betty" "comics")
    ("Big Nate"  "Lincoln Pierce"
     "Big_Nate"
     comics-get-comics-dot-com "bignate" "comics")
    ("Big Picture" "Lennie Peterson"
     "Big_Picture"
     comics-get-ucomics-dot-com "bi" "gif")
    ("Big Top" "Rob Harrell"
     "Big_Top"
     comics-get-ucomics-dot-com "bt" "gif")
    ("Blue Rice" "Shachar Meron"
     "Blue_Rice"
     comics-get-comicssherpa-dot-com-latest "csplp")
    ("Bo Nanas" "John Kovaleski"
     "Bo_Nanas"
     comics-get-comics-dot-com "bonanas" "wash")
    ("Bo Ring Adventures" "Erik Nodacker"
     "Bo_Ring_Adventures"
     comics-get-comicssherpa-dot-com-latest "cspsz")
    ("Bob the Squirrel" "Frank Page"
     "Bob_the_Squirrel"
     comics-get-ucomics-dot-com "bob" "gif")
    ("Bonser" "Rory Bonser"
     "Bonser"
     comics-get-comicssherpa-dot-com-latest "csany")
    ("The Boondocks" "Aaron McGruder"
     "Boondocks"
     comics-get-ucomics-dot-com "bo" "gif")
    ("The Born Loser"  "Chip Sansom"
     "Born_Loser"
     comics-get-comics-dot-com "bornloser" "comics")
    ("Born Lucky" "Bruce Plante"
     "Born_Lucky"
     comics-get-ucomics-dot-com-latest "bornlucky" "bol")
    ("Bottle Rocket Chronicles" "Rob McClurkan"
     "Bottle_Rocket_Chronicles"
     comics-get-comicssherpa-dot-com-latest "csuet")
    ("Bottom Feeders" "Jason Black"
     "Bottom_Feeders"
     comics-get-comicssherpa-dot-com-latest "csedq")
    ("Bottom Liners" "Eric and Bill Teitelbaum"
     "Bottom_Liners"
     comics-get-ucomics-dot-com "tmbot" "gif")
    ("Bound & Gagged" "Dana Summers"
     "Bound_and_Gagged"
     comics-get-ucomics-dot-com "tmbou" "gif")
    ("Brain Squirts" "Frank Cummings"
     "Brain_Squirts"
     comics-get-comicssherpa-dot-com-latest "cskjh")
    ("Brain Waves" "Betsy Streeter"
     "Brain_Waves"
     comics-get-comicssherpa-dot-com-latest "cshbo")
    ("Brenda Starr" "June Brigman and Mary Schmich"
     "Brenda_Starr"
     comics-get-ucomics-dot-com "tmbre" "gif")
    ("Broom-Hilda" "Russell Myers"
     "Broom_Hilda"
     comics-get-ucomics-dot-com "tmbro" "gif")
    ("The Brothers Brady" "Mike and Scott Brady"
     "Brothers_Brady"
     comics-get-comicssherpa-dot-com-latest "csxfu")
    ("The Buckets"  "Scott Santis and Greg Cravens"
     "Buckets"
     comics-get-comics-dot-com "buckets" "comics")
    ("Bull$ 'N' Bear$"  "Wells and Lindstrom"
     "Bulls_and_Bears"
     comics-get-comics-dot-com "bullsnbears" "comics"))
   ("C"
    ("Calvin & Hobbes" "Bill Watterson"
     "Calvin_and_Hobbes"
     comics-get-calvin-at-ucomics-dot-com)
    ("Candorville" "Darrin Bell"
     "Candorville"
     comics-get-comics-dot-com "candorville" "wash")
    ("Captain Ribman" "John Sprengelmeyer and Rich Davis"
     "Captain_Ribman"
     comics-get-ucomics-dot-com-latest "captainribman" "tmcap")
    ("A Case in Point" "Rob Esmay"
     "Case_in_Point"
     comics-get-comics-dot-com "acaseinpoint" "comics")
    ("Cathy" "Cathy Guiswite"
     "Cathy"
     comics-get-ucomics-dot-com "ca" "gif")
    ("Cats with Hands" "Joe Martin"
     "Cats_with_Hands"
     comics-get-ucomics-dot-com "tmcat" "gif")
    ("CEO Dad" "Tom Stern and C. Covert Darbyshire"
     "CEO_Dad"
     comics-get-comics-dot-com "ceodad" "creators")
    ("C'est la Vie" "Jennifer Miyuki Babcock"
     "Cest_la_Vie"
     comics-get-comicssherpa-dot-com-latest "csxck")
    ("Check Please!" "Matthew Meskel"
     "Check_Please"
     comics-get-comicssherpa-dot-com-latest "csspe")
    ("Cheap Thrills"  "Thach Bui and Bill Lombardo"
     "Cheap_Thrills"
     comics-get-comics-dot-com-latest "cheap_thrills" "wash")
    ("Chilling Out" "Stephen Francis and Rico Schacherl"
     "Chilling_Out"
     comics-get-comicssherpa-dot-com-latest "csldm")
;    ("Citizen Dog" "Mark O'Hare"
;     "Citizen_Dog"
;     comics-get-ucomics-dot-com "cd" "gif")
    ("Clam Boy" "Marty Wilsey and Gerald McGee"
     "Clam_Boy"
     comics-get-comicssherpa-dot-com-latest "csoef")
    ("Clean Blue Water" "Karen Montague-Reyes"
     "Clean_Blue_Water"
     comics-get-ucomics-dot-com "cbw" "gif")
    ("Cleats" "Bill Hinds"
     "Cleats"
     comics-get-ucomics-dot-com "cle" "gif")
    ("Close to Home" "John McPherson"
     "Close_to_Home"
     comics-get-ucomics-dot-com "cl" "gif")
    ("Clutter Gutter" "Rick Faris and Adam Wiater"
     "Clutter_Gutter"
     comics-get-comicssherpa-dot-com-latest "csavj")
    ("Comics by Salamon" "Joe Salamon"
     "Comics_by_Salamon"
     comics-get-comicssherpa-dot-com-latest "csphr")
    ("Committed"  "Michael Fry"
     "Committed"
     comics-get-comics-dot-com "committed" "comics")
    ("Compu-toon" "Charles Boyce"
     "Computoon"
     comics-get-ucomics-dot-com-latest "compu-toon" "tmcom")
    ("Conscious Pilot" "Chris Bautz"
     "Conscious_Pilot"
     comics-get-comicssherpa-dot-com-latest "csjvm")
    ("Cool Beans" "Richard Dominguez"
     "Cool_Beans"
     comics-get-comicssherpa-dot-com-latest "cswvq")
    ("Cornered" "Mike Baldwin"
     "Cornered"
     comics-get-ucomics-dot-com "co" "gif")
    ("Crunchy" "Francis Bonnet"
     "Crunchy"
     comics-get-comicssherpa-dot-com-latest "cscek"))
   ("D"
    ("Dandy & Company" "Derrick Fish"
     "Dandy_and_Company"
     comics-get-comicssherpa-dot-com-latest "csqrv")
    ("Dead Last" "Matty Meegan"
     "Dead_Last"
     comics-get-comicssherpa-dot-com-latest "csdpp")
    ("Dick Tracy" "Dick Locher and Michael Killian"
     "Dick_Tracy"
     comics-get-ucomics-dot-com "tmdic" "gif")
    ("Dilbert"  "Scott Adams"
     "Dilbert"
     comics-get-dilbert)
    ("Ditto & Chance" "George F. Anzaldi, Jr."
     "Ditto_and_Chance"
     comics-get-comicssherpa-dot-com-latest "csypx")
    ("Dog Complex" "Dave Johnson"
     "Dog_Complex"
     comics-get-comicssherpa-dot-com-latest "csjvc")
    ("Dog eat Doug" "Brian Anderson"
     "Dog_eat_Doug"
     comics-get-comicssherpa-dot-com-latest "cslkd")
    ("Domestic World" "Charles Stouff"
     "Domestic_World"
     comics-get-comicssherpa-dot-com-latest "csioc")
    ("The Dann Duke Show" "Steven Duquette"
     "Dann_Duke_Show"
     comics-get-comicssherpa-dot-com-latest "csynn")
    ("Doodles" "Steve Sack and Craig Macintosh"
     "Doodles"
     comics-get-ucomics-dot-com-latest "doodles" "tmdoo")
    ("Doonesbury" "Garry Trudeau"
     "Doonesbury"
     comics-get-ucomics-dot-com "db" "gif")
    ("Doctor Fun"  "David Farley"
     "Doctor_Fun"
     comics-get-doctor-fun)
    ("Drabble"  "Kevin Fagan"
     "Drabble"
     comics-get-comics-dot-com "drabble" "comics")
    ("Dumbbellz" "Bill Temples"
     "Dumbbellz"
     comics-get-comicssherpa-dot-com-latest "csafd")
    ("The Duplex" "Glenn McCoy"
     "Duplex"
     comics-get-ucomics-dot-com "dp" "gif"))
   ("F"
    ("Fat Cats"  "Charlie Podrebarac"
     "Fat_Cats"
     comics-get-comics-dot-com "fatcats" "comics")
    ("Fathead" "Graeme Hulse"
     "Fathead"
     comics-get-comicssherpa-dot-com-latest "csznj")
    ("Ferd'nand" "Henrik Rehr"
     "Ferdnand"
     comics-get-comics-dot-com "ferdnand" "comics")
    ("The 5th Wave" "Rich Tennant"
     "Fifth_Wave"
     comics-get-ucomics-dot-com-latest "thefifthwave" "fw")
    ("Fighting Words" "No Mind"
     "Fighting_Words"
     comics-get-comicssherpa-dot-com-latest "csnav")
    ("Flatland" "Grant Rogers"
     "Flatland"
     comics-get-comicssherpa-dot-com-latest "csqof")
    ("Flight Deck"  "Peter Waldner"
     "Flight_Deck"
     comics-get-comics-dot-com "flightdeck" "creators")
    ("Flo & Friends" "John Gibel and Jenny Campbell"
     "Flo_and_Friends"
     comics-get-comics-dot-com "floandfriends""creators")
    ("For Better or For Worse" "Lynn Johnston"
     "For_Better_or_For_Worse"
     comics-get-ucomics-dot-com "fb" "gif")
    ("For Pete's Sake" "Pete Papanos"
     "For_Petes_Sake"
     comics-get-comicssherpa-dot-com-latest "csfgr")
    ("FoxTrot" "Bill Amend"
     "FoxTrot"
     comics-get-ucomics-dot-com "ft" "gif")
    ("Frank & Ernest"  "Bob Thaves"
     "Frank_and_Ernest"
     comics-get-comics-dot-com "franknernest" "comics")
    ("Frazz" "Jef Mallett"
     "Frazz"
     comics-get-comics-dot-com "frazz" "comics")
    ("Freak Enterprises" "Butch Berry"
     "Freak_Enterprises"
     comics-get-comicssherpa-dot-com-latest "cscqe")
    ("Fred Basset" "Alex Graham"
     "Fred_Basset"
     comics-get-ucomics-dot-com "tmfba" "gif")
    ("Funky Winkerbean" "Tom Batiuk"
     "Funky_Winkerbean"
     comics-get-kingfeatures-dot-com "Funky_Winkerbean")
    ("Fusco Brothers" "J.C. Duffy"
     "Fusco_Brothers"
     comics-get-ucomics-dot-com "fu" "gif"))
   ("G"
    ("Garfield" "Jim Davis"
     "Garfield"
     comics-get-ucomics-dot-com "ga" "gif")
    ("Gasoline Alley" "Jim Scancarelli"
     "Gasoline_Alley"
     comics-get-ucomics-dot-com "tmgas" "gif")
    ("Geech"  "Jerry Bittle"
     "Geech"
     comics-get-comics-dot-com "geech" "comics")
    ("Get Fuzzy"  "Darby Conley"
     "Get_Fuzzy"
     comics-get-comics-dot-com "getfuzzy" "comics")
    ("Gil Thorp" "Neal Rubin and Frank McLaughlin"
     "Gil_Thorp"
     comics-get-ucomics-dot-com "tmgil" "gif")
    ("Ginger & Shadow" "Barry Corbett"
     "Ginger_and_Shadow"
     comics-get-comicssherpa-dot-com-latest "csndk")
    ("Girl Genius" "Phil & Kaja Foglio"
     "Girl_Genius"
     comics-get-girl-genius)
    ("Go Fish" "J.C. Duffy"
     "Go_Fish"
     comics-get-comics-dot-com "gofish" "comics")
    ("G.O.R.K." "Craig A. Doucette"
     "Gork"
     comics-get-comicssherpa-dot-com-latest "csrqs")
    ("Graffiti" "Gene Mora"
     "Graffiti"
     comics-get-comics-dot-com "graffiti" "comics")
    ("Grand Avenue"  "Steve Breen"
     "Grand_Avenue"
     comics-get-comics-dot-com "grandave" "comics")
    ("The Grizzwells"  "Bill Schorr"
     "Grizzwells"
     comics-get-comics-dot-com "grizzwells" "comics")
    ("Gutters" "Todd Pound"
     "Gutters"
     comics-get-comicssherpa-dot-com-latest "gutt"))
   ("H"
    ("Hamm's Hallucination" "Johnny Hamm"
     "Hamms_Hallucination"
     comics-get-comicssherpa-dot-com-latest "csbrr")
    ("HD&P Comic Strips" "Shawn Lindseth"
     "HD_and_P_Comic_Strips"
     comics-get-comicssherpa-dot-com-latest "csaqe")
    ("Heart of the City" "Mark Tatulli"
     "Heart_of_the_City"
     comics-get-ucomics-dot-com "hc" "gif")
    ("Heathcliff"  "George Gately"
     "Heathcliff"
     comics-get-comics-dot-com "heathcliff" "creators")
    ("Helen, Sweetheart of the Internet" "Peter Zale"
     "Helen_Sweetheart_of_the_Internet"
     comics-get-ucomics-dot-com "tmhel" "gif")
    ("Herb and Jamaal" "Stephen Bentley"
     "Herb_and_Jamaal"
     comics-get-comics-dot-com "herbnjamaal" "creators")
    ("Herman"  "Jim Unger"
     "Herman"
     comics-get-comics-dot-com "herman" "comics")
    ("Housebroken" "Steve Watkins"
     "Housebroken"
     comics-get-ucomics-dot-com "tmhou" "gif")
    ("Hubert Abby" "Mel Henze"
     "Hubert_Abby"
     comics-get-comicssherpa-dot-com-latest "cskvb")
    ("The Humble Stumble" "Roy Schneider"
     "Humble_Stumble"
     comics-get-comics-dot-com "humblestumble" "comics"))
   ("I"
    ("I Don't Get It" "Steven Stehle"
     "I_Dont_Get_It"
     comics-get-comicssherpa-dot-com-latest "cszyi")
;    ("Idiot Box" "Matt Bors"
;     "Idiot_Box"
;     comics-get-comicssherpa-dot-com-latest "cslvb")
    ("In Other News..." "Lars deSouza and Ryan Sohmer"
     "In_Other_News"
     comics-get-comicssherpa-dot-com-latest "csojc")
    ("In Search Of" "Gabe Kempe"
     "In_Search_Of"
     comics-get-comicssherpa-dot-com-latest "csjlu")
    ("In The Bleachers" "Steve Moore"
     "In_The_Bleachers"
     comics-get-ucomics-dot-com "bl" "gif")
    ("Isn't That The Truth" "Mike Moore"
     "Isnt_That_The_Truth"
     comics-get-comicssherpa-dot-com-latest "csssk"))
   ("J"
    ("Jack Velvet" "Dean Prefest"
     "Jack_Velvet"
     comics-get-comicssherpa-dot-com-latest "csfsy")
    ("James" "Mark Tonra"
     "James"
     comics-get-ucomics-dot-com-latest "james" "jm")
    ("Jane's World" "Paige Braddock"
     "Janes_World"
     comics-get-comics-dot-com "janesworld" "comics")
    ("Jayhoo and Jawhoo" "Mark Velard"
     "Jayhoo_and_Jawhoo"
     comics-get-comicssherpa-dot-com-latest "csfiy")
    ("Jest Sports" "Roy Delgado"
     "Jest_Sports"
     comics-get-comics-dot-com "jestsports" "comics")
    ("Joel and Steve" "Stan W. Kost"
     "Joel_and_Steve"
     comics-get-comicssherpa-dot-com-latest "csfeb")
    ("Jump Start" "Robb Armstrong"
     "Jump_Start"
     comics-get-comics-dot-com "jumpstart" "comics"))
   ("K"
    ("Killing Time" "Ned"
     "Killing_Time"
     comics-get-comicssherpa-dot-com-latest "csblh")
    ("Kit 'N' Carlyle" "Larry Wright"
     "Kit_n_Carlyle"
     comics-get-comics-dot-com "kitncarlyle" "comics")
    ("Kudzu" "Doug Marlette"
     "Kudzu"
     comics-get-ucomics-dot-com "tmkud" "gif"))
   ("L"
    ("La Cucaracha" "Lalo Alcaraz"
     "La_Cucaracha"
     comics-get-ucomics-dot-com "lc" "gif")
    ("Labgoats, Inc." "Petie Shumate"
     "Labgoats_Inc"
     comics-get-comicssherpa-dot-com-latest "csafe")
    ("Learning Laffs" "John P. Wood"
     "Learning_Laffs"
     comics-get-comicssherpa-dot-com-latest "cswgt")
    ("Lemon 13" "Larry Scarborough"
     "Lemon_13"
     comics-get-comicssherpa-dot-com-latest "csqne")
    ("Liberty Meadows" "Frank Cho"
     "Liberty_Meadows"
     comics-get-comics-dot-com "liberty" "creators")
;    ("Li'l Abner" "Al Capp"
;     "Lil_Abner"
;     comics-get-comics-dot-com "lilabner" "comics")
    ("liquid thought" "robert e g black"
     "Liquid_thought"
     comics-get-comicssherpa-dot-com-latest "cskwm")
    ("Lola" "Steve Dickenson and Todd Clark"
     "Lola"
     comics-get-ucomics-dot-com "tmlol" "gif")
    ("Loose Parts" "Dave Blazek"
     "Loose_Parts"
     comics-get-ucomics-dot-com "tmloo" "gif")
    ("Lost Sheep" "Dan Thompson"
     "Lost_Sheep"
     comics-get-ucomics-dot-com "lost" "gif")
    ("Luann" "Greg Evans"
     "Luann"
     comics-get-comics-dot-com "luann" "comics")
    ("Lucky Cow" "Mark Pett"
     "Lucky_Cow"
     comics-get-ucomics-dot-com "luc" "gif")
;    ("Lunar Antics" "Bob Walters"
;     "Lunar_Antics"
;     comics-get-comicssherpa-dot-com-latest "csrbl")
    ("Lupo Alberto" "Silver"
     "Lupo_Alberto"
     comics-get-comics-dot-com "lupo" "comics"))
   ("M"
    ("Maddog: Ghetto Cop" "Stanislaus P. Ortega"
     "Maddog_Ghetto_Cop"
     comics-get-comicssherpa-dot-com-latest "cskwp")
    ("Marmaduke" "Brad Anderson"
     "Marmaduke"
     comics-get-comics-dot-com "marmaduke" "comics")
    ("Meatloaf Night" "Mark Buford"
     "Meatloaf_Night"
     comics-get-comics-dot-com "meatloaf" "comics")
    ("Meg!" "Greg Curfman"
     "Meg"
     comics-get-comics-dot-com "meg" "comics")
    ("Meehan Streak" "Kieran Meehan"
     "Meehan_Streak"
     comics-get-ucomics-dot-com "tmmee" "gif")
    ("The Middletons" "Ralph Dunagin and Dana Summers"
     "Middletons"
     comics-get-ucomics-dot-com "tmmid" "gif")
    ("Mike & Eric" "Eric Paul Johnson"
     "Mike_and_Eric"
     comics-get-comicssherpa-dot-com-latest "csvvw")
    ("Mister Boffo" "Joe Martin"
     "Mister_Boffo"
     comics-get-ucomics-dot-com "mb" "gif")
    ("Mixed Media" "Scott Willis and Jack Ohman"
     "Mixed_Media"
     comics-get-ucomics-dot-com "tmmix" "gif")
    ("Moderately Confused" "Jeff Stahler"
     "Moderately_Confused"
     comics-get-comics-dot-com "moderatelyconfused" "comics")
    ("Momma" "Mell Lazarus"
     "Momma"
     comics-get-comics-dot-com "momma" "creators")
    ("MonkeyNaut" "Mat Pruneda and Jaime Paxton"
     "MonkeyNaut"
     comics-get-comicssherpa-dot-com-latest "cswer")
    ("Monty" "Jim Meddick"
     "Monty"
     comics-get-comics-dot-com "monty" "comics")
    ("Motley" "Larry Wright"
     "Motley"
     comics-get-comics-dot-com "motley" "comics")
    ("Muck" "G.E. Koenig"
     "Muck"
     comics-get-comicssherpa-dot-com-latest "csfea")
    ("Mullets" "Rick Stromoski and Steve McGarry"
     "Mullets"
     comics-get-ucomics-dot-com "mul" "gif")
    ("The Munchies" "Jason Gluskin"
     "Munchies"
     comics-get-comicssherpa-dot-com-latest "csqsk")
    ("Mutts" "Patrick McDonnell" "Mutts"
     comics-get-mutts)
    ("Myth-Tickle" "Justin Thompson"
     "Myth_Tickle"
     comics-get-comicssherpa-dot-com-latest "csnyh"))
   ("N"
    ("Nancy" "Guy and Brad Gilchrist"
     "Nancy"
     comics-get-comics-dot-com "nancy" "comics")
    ("Natural Selection" "Russ Wallace"
     "Natural_Selection"
     comics-get-comics-dot-com "naturalselection" "creators")
    ("Neighbors" "Steve Phelps"
     "Neighbors"
     comics-get-comicssherpa-dot-com-latest "csxsd")
    ("No Business I Know" "Doug Crepeau and Kevin Hopkins"
     "No_Business_I_Know"
     comics-get-comicssherpa-dot-com-latest "csmfg")
    ("Non Sequitur" "Wiley Miller"
     "Non_Sequitur"
     comics-get-ucomics-dot-com "nq" "gif"))
   ("O"
    ("Oddly Enough" "Chris Kemp"
     "Oddly_Enough"
     comics-get-ucomics-dot-com "oe" "gif")
    ("Off the Mark" "Mark Parisi"
     "Off_the_Mark"
     comics-get-comics-dot-com "offthemark" "comics")
;    ("Offworlders" "James Bradbury"
;     "Offworlders"
;     comics-get-comicssherpa-dot-com-latest "csiwh")
    ("One Big Happy" "Rick Detorie"
     "One_Big_Happy"
     comics-get-comics-dot-com "onebighappy" "creators")
    ("One Nation, Under Dog" "Kurt Jensen and Mike Martone"
     "One_Nation_Under_Dog"
     comics-get-comicssherpa-dot-com-latest "csuwn")
    ("The Other Coast" "Adrian Raeside"
     "Other_Coast"
     comics-get-comics-dot-com "othercoast" "creators")
    ("Out of the Gene Pool" "Matt Janz"
     "Out_of_the_Gene_Pool"
     comics-get-comics-dot-com "genepool" "wash")
    ("Over the Hedge" "Michael Fry and T Lewis"
     "Over_the_Hedge"
     comics-get-comics-dot-com "hedge" "comics")
    ("Overboard" "Chip Dunham"
     "Overboard"
     comics-get-ucomics-dot-com "ob" "gif"))
   ("P"
    ("Patent Sweater" "Ali Fitzgerald"
     "Patent_Sweater"
     comics-get-comicssherpa-dot-com-latest "csnhm")
    ("PC and Pixel" "Thach Bui"
     "PC_and_Pixel"
     comics-get-comics-dot-com "pcnpixel" "wash")
    ("Peanuts" "Charles Schulz"
     "Peanuts"
     comics-get-comics-dot-com "peanuts" "comics")
    ("Pearls Before Swine" "Stephan Pastis"
     "Pearls_Before_Swine"
     comics-get-comics-dot-com "pearls" "comics")
    ("The Petstore" "Drew Trevlyn"
     "Petstore"
     comics-get-comicssherpa-dot-com-latest "cstde")
    ("Pibgorn" "Brooke McEldowney"
     "Pibgorn"
     comics-get-comics-dot-com "pibgorn" "comics")
    ("Pickles" "Brian Crane"
     "Pickles"
     comics-get-comics-dot-com "pickles" "wash")
    ("Piled Higher and Deeper (PhD)" "Jorge Cham"
     "Piled_Higher_and_Deeper"
     comics-get-phd)
    ("Pluggers" "Gary Brookins"
     "Pluggers"
     comics-get-ucomics-dot-com "tmplu" "gif")
    ("Police Limit" "Garey Mckee"
     "Police_Limit"
     comics-get-comicssherpa-dot-com-latest "cspcc")
    ("Pooch Cafe" "Paul Gilligan"
     "Pooch_Cafe"
     comics-get-ucomics-dot-com "poc" "gif")
    ("Pop Culture" "Steve McGarry"
     "Pop_Culture"
     comics-get-ucomics-dot-com "pop" "gif")
    ("Pop Fiction" "Greg Pepin"
     "Pop_Fiction"
     comics-get-comicssherpa-dot-com-latest "csadz")
    ("Pork and Bean" "Brian Dunaway"
     "Pork_and_Bean"
     comics-get-comicssherpa-dot-com-latest "csxcm")
    ("Preteena" "Allison Barrows"
     "Preteena"
     comics-get-ucomics-dot-com "pr" "gif")
    ("Prickly City" "Scott Stantis"
     "Prickly_City"
     comics-get-ucomics-dot-com "prc" "gif")
    ("A Princess" "Marcus Nix and Dave Fackrell"
     "Princess"
     comics-get-comicssherpa-dot-com-latest "csgem"))
   ("Q"
    ("Quietboy" "David Essman"
     "Quietboy"
     comics-get-comicssherpa-dot-com-latest "csdhm")
    ("Quigmans" "Buddy Hickerson"
     "Quigmans"
     comics-get-ucomics-dot-com "tmqui" "gif"))
   ("R"
    ("Raising Duncan" "Chris Browne"
     "Raising_Duncan"
     comics-get-comics-dot-com "raisingduncan" "comics")
    ("Randy & Roswell" "Q"
     "Randy_and_Roswell"
     comics-get-comicssherpa-dot-com-latest "cslum")
    ("Real Life Adventures" "Gary Wise and Lance Aldrich"
     "Real_Life_Adventures"
     comics-get-ucomics-dot-com "rl" "gif")
    ("Reality Check" "Dave Whamond"
     "Reality_Check"
     comics-get-comics-dot-com "reality" "comics")
    ("Red & Rover" "Brian Basset"
     "Red_and_Rover"
     comics-get-comics-dot-com "redandrover" "wash")
    ("Reynolds Unwrapped" "Dan Reynolds"
     "Reynolds_Unwrapped"
     comics-get-ucomics-dot-com-latest "reynoldsunwrapped" "rw")
    ("Ripley's Believe It or Not" "Don Wimmer and Karen Kemlo"
     "Ripleys_Believe_It_or_Not"
     comics-get-comics-dot-com "ripleys" "comics")
    ("Rose is Rose" "Pat Brady"
     "Rose_is_Rose"
     comics-get-comics-dot-com "roseisrose" "comics")
    ("RQW" "Ray Friesen"
     "RQW"
     comics-get-comicssherpa-dot-com-latest "csbeo")
    ("Rubes" "Leigh Rubin"
     "Rubes"
     comics-get-comics-dot-com "rubes" "creators")
    ("Rudy Park" "Darrin Bell and Theron Heir"
     "Rudy_Park"
     comics-get-comics-dot-com "rudypark" "comics")
    ("Run Wild" "J.G. Moore"
     "Run_Wild"
     comics-get-comicssherpa-dot-com-latest "csyya"))
   ("S"
    ("Sheldon" "Dave Kellett"
     "Sheldon"
     comics-get-comics-dot-com "sheldon" "comics")
    ("Shirley and Son" "Jerry Bittle"
     "Shirley_and_Son"
     comics-get-comics-dot-com "shirleynson" "comics")
    ("Shoe" "Chris Cassatt and Gary Brockins"
     "Shoe"
     comics-get-ucomics-dot-com "tmsho" "gif")
    ("Shoecabbage" "Teresa Dowlatshahi and David Stanford"
     "Shoecabbage"
     comics-get-ucomics-dot-com "shcab" "gif")
    ("ShortPacked" "David Willis"
     "ShortPacked" 
     comics-get-shortpacked)
    ("Single Simon" "Don Cresci"
     "Single_Simon"
     comics-get-comicssherpa-dot-com-latest "csjhk")
    ("Slightly Skewed" "j. Daly"
     "Slightly_Skewed"
     comics-get-comicssherpa-dot-com-latest "cswcu")
    ("Snoopy" "Charles Schulz"
     "Snoopy"
     comics-get-snoopy-at-snoopy-co-jp)
    ("The Social Outcast" "Richard Lillie"
     "Social_Outcast"
     comics-get-comicssherpa-dot-com-latest "csvsq")
    ("South of Town" "Dave Fackrell"
     "South_of_Town"
     comics-get-comicssherpa-dot-com-latest "csdkh")
    ("Space is the Place" "Tom Verheijen"
     "Space_is_the_Place"
     comics-get-comicssherpa-dot-com-latest "csxpo")
    ("Speed Bump" "Dave Coverly"
     "Speed_Bump"
     comics-get-comics-dot-com "speedbump" "creators")
    ("Spot the Frog" "Mark Heath"
     "Spot_the_Frog"
     comics-get-comics-dot-com "spotthefrog" "comics")
    ("Standup Comics" "Basil White"
     "Standup_Comics"
     comics-get-comicssherpa-dot-com-latest "cswcd")
    ("Stik Monkey" "Raymond Kasel"
     "Stik_Monkey"
     comics-get-comicssherpa-dot-com-latest "csibs")
    ("Stone Soup" "Jan Eliot"
     "Stone_Soup"
     comics-get-ucomics-dot-com "ss" "gif")
    ("Strange Brew" "John Deering"
     "Strange_Brew"
     comics-get-comics-dot-com "strangebrew" "creators")
    ("The Sunshine Club" "Howie Schneider"
     "Sunshine_Club"
     comics-get-comics-dot-com "sunshineclub" "comics")
    ("Sylvia" "Nicole Hollander"
     "Sylvia"
     comics-get-ucomics-dot-com "tmsyl" "gif")
    ("Syntax Errors" "Damon Riesberg"
     "Syntax_Errors"
     comics-get-comicssherpa-dot-com-latest "csjxz"))
   ("T"
    ("Tank McNamara" "Jeff Millar and Bill Hinds"
     "Tank_McNamara"
     comics-get-ucomics-dot-com "tm" "gif")
    ("Tarzan" "Edgar Rice Burroughs"
     "Tarzan"
     comics-get-comics-dot-com "tarzan" "comics")
    ("That's Life" "Mike Twohy"
     "Thats_Life"
     comics-get-comics-dot-com "thatslife" "wash")
    ("Todd and Penguin" "David Wright"
     "Todd_and_Penguin"
     comics-get-comicssherpa-dot-com-latest "csska")
    ("Tom the Dancing Bug" "Ruben Bolling"
     "Tom_the_Dancing_Bug"
     comics-get-ucomics-dot-com-latest "tomthedancingbug" "td")
    ("Top of the World!" "Mark Tonra"
     "Top_of_the_World"
     comics-get-comics-dot-com "topofworld" "comics")
    ("TRENDZ" "W.W. Olsen"
     "Trendz"
     comics-get-comicssherpa-dot-com-latest "csaab")
    ("A Twisted Mind" "Skip Towne"
     "Twisted_Mind"
     comics-get-comicssherpa-dot-com-latest "csjyk"))
   ("U"
    ("Unibug" "Pujan Roka"
     "Unibug"
     comics-get-comicssherpa-dot-com-latest "csmen")
    ("User Friendly" "J.D. Frazer"
     "User_Friendly"
     comics-get-user-friendly))
   ("V"
    ("Vern & Dern" "Stephen Francis and Rico Schacherl"
     "Vern_and_Dern"
     comics-get-comicssherpa-dot-com-latest "csasy"))
   ("W"
    ("Wally Gilmore" "rick jacobs"
     "Wally_Gilmore"
     comics-get-comicssherpa-dot-com-latest "csgty")
    ("Whatever USA" "Larry C. Bernstein"
     "Whatever_USA"
     comics-get-comicssherpa-dot-com-latest "csabd")
    ("Who's Teaching Who" "C.L. Hansen"
     "Whos_Teaching_Who"
     comics-get-comicssherpa-dot-com-latest "csapl")
    ("The Widget Box" "Harry Martin"
     "Widget_Box"
     comics-get-comicssherpa-dot-com-latest "csedm")
    ("Wild Unknown" "Kellie Lewis"
     "Wild_Unknown"
     comics-get-comicssherpa-dot-com-latest "cslwd")
    ("Willy 'n' Ethel" "Joe Martin"
     "Willy_and_Ethel"
     comics-get-ucomics-dot-com "wes" "gif")
    ("Wizard of Id" "Brant Parker and Johnny Hart"
     "Wizard_of_Id"
     comics-get-comics-dot-com "wizardofid" "creators")
    ("Wohlnuts" "Phil Wohlrab"
     "Wohlnuts"
     comics-get-comicssherpa-dot-com-latest "cswip")
    ("Words of Wisdumb" "Thom Bluemel"
     "Words_of_Wisdumb"
     comics-get-comicssherpa-dot-com-latest "csvel")
    ("Working Daze" "John Zakour and Kyle Miller"
     "Working_Daze"
     comics-get-comics-dot-com "workingdaze" "comics")
    ("Working It Out" "Charlos Gary"
     "Working_It_Out"
     comics-get-comics-dot-com "workingitout" "creators")
    ("Wulffmorgenthaler" "Mikael Wulff and Anders Morgenthaler"
     "Wulffmorgenthaler"
     comics-get-comicssherpa-dot-com-latest "cstiq"))
   ("X"
    ("Xkcd" "Randall Munroe"
     "Xkcd"
     comics-get-xkcd))
   ("Y"
    ("Yenny" "David Alvarez"
     "Yenny"
     comics-get-comicssherpa-dot-com-latest "csaeb")
    ("The Young Breed" "J. Foster"
     "Young_Breed"
     comics-get-comicssherpa-dot-com-latest "csspf"))
   ("Z"
    ("Ziggy" "Tom Wilson and Tom II"
     "Ziggy"
     comics-get-ucomics-dot-com "zi" "gif")
    ("Zippy the Pinhead"  "Bill Griffith"
     "Zippy_The_Pinhead"
     comics-get-zippy-the-pinhead)
    ("Zits" "Jeremy Scott & Jim Borgman"
     "Zits"
     comics-get-kingfeatures-dot-com "Zits")
    ("The Zoo" "Gabe Strine"
     "Zoo"
     comics-get-comicssherpa-dot-com-latest "csmgp"))
   ("EDITORIAL CARTOONS"
    ("Lalo Alcaraz" ""
     "Editorial-Lalo_Alcaraz"
     comics-get-ucomics-dot-com-latest "laloalcaraz" "la")
    ("Robert Ariail" ""
     "Editorial-Robert_Ariail"
     comics-get-comics-dot-com-latest "ariail" "editoons")
    ("Chuck Asay" ""
     "Editorial-Chuck_Asay"
     comics-get-comics-dot-com-latest "asay" "editoons")
    ("Tony Auth" ""
     "Editorial-Tony_Auth"
     comics-get-ucomics-dot-com-latest "tonyauth" "ta")
    ("Steve Benson" ""
     "Editorial-Steve_Benson"
     comics-get-comics-dot-com-latest "benson" "editoons")
    ("Chip Bok" ""
     "Editorial-Chip_Bok"
     comics-get-comics-dot-com-latest "bok" "editoons")
    ("Stuart Carlson" ""
     "Editorial-Stuart_Carlson"
     comics-get-ucomics-dot-com-latest "stuartcarlson" "sc")
    ("Paul Conrad" ""
     "Editorial-Paul_Conrad"
     comics-get-ucomics-dot-com-latest "paulconrad" "tmpco")
    ("Jeff Danziger" ""
     "Editorial-Jeff_Danziger"
     comics-get-ucomics-dot-com-latest "jeffdanziger" "jd")
    ("Matt Davies" ""
     "Editorial-Matt_Davies"
     comics-get-ucomics-dot-com-latest "mattdavies" "tmmda")
    ("Bill Day" ""
     "Editorial-Bill_Day"
     comics-get-comics-dot-com-latest "day" "editoons")
    ("Bill DeOre" ""
     "Editorial-Bill_DeOre"
     comics-get-ucomics-dot-com-latest "billdeore" "bd")
    ("Faces in the News" "Kerry Waghorn"
     "Faces_in_the_News"
     comics-get-ucomics-dot-com-latest "facesinthenews" "kw")
    ("Walt Handelsman" ""
     "Editorial-Walt_Handelsman"
     comics-get-ucomics-dot-com-latest "walthandelsman" "tmwha")
    ("Jack Higgins" ""
     "Editorial-Jack_Higgins"
     comics-get-ucomics-dot-com-latest "jackhiggins" "jh")
    ("Jerry Holbert" ""
     "Editorial-Jerry_Holbert"
     comics-get-comics-dot-com-latest "holbert" "editoons")
    ("David Horsey" ""
     "Editorial-David_Horsey"
     comics-get-ucomics-dot-com-latest "davidhorsey" "tmdho")
    ("Etta Hulme" ""
     "Editorial-Etta_Hulme"
     comics-get-comics-dot-com-latest "hulme" "editoons")
    ("Drew Litton" ""
     "Editorial-Drew_Litton"
     comics-get-comics-dot-com-latest "litton" "editoons")
    ("Dick Locher" ""
     "Editorial-Dick_Locher"
     comics-get-ucomics-dot-com-latest "dicklocher" "tmdlo")
    ("Chan Lowe" ""
     "Editorial-Chan_Lowe"
     comics-get-ucomics-dot-com-latest "chanlowe" "tmclo")
    ("Mike Luckovich" ""
     "Editorial-Mike_Luckovich"
     comics-get-comics-dot-com-latest "luckovich" "editoons")
    ("Doug Marlette" ""
     "Editorial-Doug_Marlette"
     comics-get-ucomics-dot-com-latest "dougmarlette" "tmdma")
    ("Glenn McCoy" ""
     "Editorial-Glenn_McCoy"
     comics-get-ucomics-dot-com-latest "glennmccoy" "gm")
    ("Jack Ohman" ""
     "Editorial-Jack_Ohman"
     comics-get-ucomics-dot-com-latest "jackohman" "tmjoh")
    ("Pat Oliphant" ""
     "Editorial-Pat_Oliphant"
     comics-get-ucomics-dot-com-latest "patoliphant" "po")
    ("Henry Payne" ""
     "Editorial-Henry_Payne"
     comics-get-comics-dot-com-latest "payne" "editoons")
    ("Joel Pett" ""
     "Editorial-Joel_Pett"
     comics-get-ucomics-dot-com-latest "joelpett" "jp")
    ("Ted Rall" ""
     "Editorial-Ted_Rall"
     comics-get-ucomics-dot-com-latest "tedrall" "tr")
    ("Rob Rogers" ""
     "Editorial-Rob_Rogers"
     comics-get-comics-dot-com-latest "rogers" "editoons")
    ("Steve Sack" ""
     "Editorial-Steve_Sack"
     comics-get-ucomics-dot-com-latest "stevesack" "tmssa")
    ("Ben Sargent" ""
     "Editorial-Ben_Sargent"
     comics-get-ucomics-dot-com-latest "bensargent" "bs")
    ("Bill Schorr" ""
     "Editorial-Bill_Schorr"
     comics-get-comics-dot-com-latest "schorr" "editoons")
    ("Drew Sheneman" ""
     "Editorial-Drew_Sheneman"
     comics-get-ucomics-dot-com-latest "drewsheneman" "tmdsh")
    ("Jeff Stahler" ""
     "Editorial-Jeff_Stahler"
     comics-get-comics-dot-com-latest "stahler" "editoons")
    ("Wayne Stayskal" ""
     "Editorial-Wayne_Stayskal"
     comics-get-ucomics-dot-com-latest "waynestayskal" "tmwst")
    ("Ed Stein" ""
     "Editorial-Ed_Stein"
     comics-get-comics-dot-com-latest "stein" "editoons")
    ("Dana Summers" ""
     "Editorial-Dana_Summers"
     comics-get-ucomics-dot-com-latest "danasummers" "tmdsu")
    ("Paul Szep" ""
     "Editorial-Paul_Szep"
     comics-get-comics-dot-com-latest "szep" "editoons")
    ("Ann Telnaes" ""
     "Editorial-Ann_Telnaes"
     comics-get-ucomics-dot-com-latest "anntelnaes" "tmate")
    ("Tom Toles" ""
     "Editorial-Tom_Toles"
     comics-get-ucomics-dot-com-latest "tomtoles" "tt")
    ("Gary Varvel" ""
     "Editorial-Gary_Varvel"
     comics-get-comics-dot-com-latest "varvel" "editoons")
    ("Dan Wasserman" ""
     "Editorial-Dan_Wasserman"
     comics-get-ucomics-dot-com-latest "danwasserman" "tmdwa")
    ("Where Im Coming From" "Barbara Brandon-Croft"
     "Where_Im_Coming_From"
     comics-get-ucomics-dot-com-latest "barbarabrandon" "bb")
    ("Dick Wright" ""
     "Editorial-Dick_Wright"
     comics-get-ucomics-dot-com-latest "dickwright" "tmdiw")
    ("Don Wright" ""
     "Editorial-Don_Wright"
     comics-get-ucomics-dot-com-latest "donwright" "tmdow")
    ("Your Angels Speak" "Guy Gilchrist"
     "Your_Angels_Speak"
     comics-get-comics-dot-com-latest "yourangelsspeak" "editoons")))
"This is a list of so-called comic categories.
Each category is a list beginning with a string (the name), followed by 
sublists of comics in that category.
Each sublist must consist of 
NAME      The name of the strip
AUTHOR    The author of the strip (or \"\")
FILENAME  A name to use in the construction of the file name
FUNCTION  A function which will fetch the strip and return the name
          of the fetched file, or nil if it cannot fetch it.  
          Any necessary arguments can follow.")
;;; This last function must take an optional last argument,
;;; which if non-nil and not "-" should be of the form
;;; YYYYMMDD and will return the strip from that day.
;;; If only the latest edition of the cartoon can be reliably 
;;; retrieved, then the function should return the string 
;;; "onlylatest" if called with an argument (besides "-").
;;; If the date YYYYMMDD is needed by the function, it should
;;; computed with (comics-use-date date timezone)
;;; where date is the optional argument of the function and
;;; timezone is a string indicating which time zone the web site
;;; is.  (See comics-world-timezones).  If date is a date, then
;;; comics-use-date will return the date.  If date is nil,
;;; the comics-use-date will return the current date at the given
;;; timezone, and if date is "-", the comics-use-date will 
;;; return the date at the computer being used.
;;; Any net comic getting functions should be added to 
;;; `comics-get-comics-timezone-list'.

;;; The time zones here are rough estimates; i.e., they've worked for
;;; me so far.  But I need to find out where the servers are at.
(defvar comics-get-comics-timezone-list
  '((comics-get-comics-dot-com "CST")
    (comics-get-ucomics-dot-com "CST")
    (comics-get-calvin-at-ucomics-dot-com "CST")
    (comics-get-girl-genius "EST")
    (comics-get-mutts "EST")
    (comics-get-user-friendly "CST")
    (comics-get-shortpacked "EST")
    (comics-get-doctor-fun "EST")
    (comics-get-zippy-the-pinhead "PST")
    (comics-get-kingfeatures-dot-com "EST")
    (comics-get-snoopy-at-snoopy-co-jp "GMT+9")))

(defvar comics-list nil
  "A list of comics, uncategorized.")

(defun comics-update-comics-list ()
  "Update the list `comics-list'.
This uses the current value of `comics-categorized-list'."
  (interactive)
  (setq comics-list (apply 'append
		       (mapcar 'cdr comics-categorized-list))))

;;; Initialize the list on loading
(comics-update-comics-list)

;;; Now, some useful functions

(defun comics-no-op ()
  "Does nothing."
  (interactive))

;; Okay; one not so useful function.

;;; The first two use wget, the only place external
;;; utilities are directly used.

(defun comics-get-string-from-url (url re n)
  "Search URL for the regexp RE, returning `match-string' N.
If no match is found, return nil."
  (let* ((newbuf (generate-new-buffer-name "comic"))
         (str)
         (case-fold-search t))
    (call-process comics-wget-program 
                  nil newbuf nil url 
                  "-q" "--output-document=-")
    (set-buffer newbuf)
    (goto-char (point-min))
    (if (re-search-forward re nil t)
        (setq str (match-string n))
      (setq str nil))
    (kill-buffer newbuf)
    str))

(defvar comics-urlonly nil)
(defun comics-get-file-at-url (url &optional xtargs)
  "Download the file at URL.
Return the file name."
  (if comics-urlonly
      (if (string-match "http" url)
          url
        "URL not available")
    (if (not (executable-find comics-wget-program))
        (message (concat "Unable to find wget program: " comics-wget-program))
      (let* ((file (expand-file-name
                    (concat 
                     comics-dir "/" 
                     (make-temp-name "comic")
                     (file-name-extension url t)))))
        (unless (file-exists-p (expand-file-name comics-dir))
          (make-directory (expand-file-name comics-dir) t))
        (if xtargs
            (call-process comics-wget-program nil nil nil 
                          xtargs url "-q" 
                          (concat "--output-document=" file))
          (call-process comics-wget-program nil nil nil url "-q" 
                        (concat "--output-document=" file)))
        (setq comics-latest-url url)
        file))))

(defun comics-get-file-at-url-inside-another-url (url re n &optional pre)
  "Go to URL, look for RE, then get the file being pointed to.
The file will be  given by PRE followed by (match-string N).
Return name of file, or nil if RE not found."
  (if (not (executable-find comics-wget-program))
      (message (concat "Unable to find wget program: " comics-wget-program))
    (let ((inside-url 
           (comics-get-string-from-url url re n)))
      (if inside-url
          (comics-get-file-at-url
           (if pre
               (concat pre inside-url)
             inside-url))
        (if comics-urlonly
            ""
          nil)))))

;;; A function for using the prompts.
(defvar ido-temp-list)
(defun comics-completing-read (prompt list &optional def)
  "Read a string in the minibuffer.
Prompt user with PROMPT, and use LIST for completions."
  (cond
   ((and
     comics-use-ido-completion
     (< emacs-major-version 22)
     (boundp 'ido-enabled)
     ido-enabled)
    (let ((ido-case-fold t)
          (ido-make-buffer-list-hook
           (lambda ()
             (setq ido-temp-list 
                   (if (consp (car-safe list))
                       (mapcar #'car list)
                     list)))))
      (ido-read-buffer prompt def)))
   ((and
     comics-use-ido-completion
     ido-mode)
    (let ((ido-case-fold t))
      (ido-completing-read prompt 
                           (if (consp (car-safe list))
                               (mapcar #'car list)
                             list)
                           nil t nil nil def)))
   (t
    (let ((completion-ignore-case t))
      (completing-read prompt list nil t nil nil def)))))

;;; Some functions for dealing with dates  

(defun comics-add-times (atime btime)
  "Add the times given by ATIME and BTIME (in form (high low))."
  ;; If atime2 + btime2 > 65536
  (if (>= (+ (cadr atime) (cadr btime)) 65536)
      (list
       (+ (car atime) (car btime) 1)
       (- (+ (cadr atime) (cadr btime)) 65536))
    (list (+ (car atime) (car btime))
          (+ (cadr atime) (cadr btime)))))

(defun comics-subtract-times (atime btime)
  "Find the time given by ATIME minus BTIME."
  ;; See if we need to borrow
  (if (< (cadr atime) (cadr btime))
      (list
       (- (car atime) (car btime) 1)
       (- (+ (cadr atime) 65536) (cadr btime)))
    (list 
     (- (car atime) (car btime))
     (- (cadr atime) (cadr btime)))))

(defun comics-hours-to-time (hrs)
  "Give a time (high low) for HRS hours."
  (list (/ (* hrs 3600) 65536)
        (% (* hrs 3600) 65536)))

(defun comics-day-to-date (day)
  "YYYYMMDD for DAY days ago (or, if DAY is nil, today."
  (let* ((ctime (current-time))
         (dy (if day day 0))
;         (dtime  (list (/ (* dy 86400) 65536)
;                      (% (* dy 86400) 65536)))
         (dtime  (list (/ (* dy 675) 512)
                       (* 128 (% (* dy 675) 512))))
         (rtime (comics-subtract-times ctime dtime)))
    (format-time-string "%Y%m%d" rtime)))

(defvar comics-world-timezones
  '(("PST"    .  -28800)
    ("PDT"    .  -25200)
    ("MST"    .  -25200)
    ("MDT"    .  -21600)
    ("CST"    .  -21600)
    ("CDT"    .  -18000)
    ("EST"    .  -18000)
    ("EDT"    .  -14400)
    ("AST"    .  -14400)
    ("NST"    .  -10830)
    ("UT"     .       0)
    ("GMT"    .       0)
    ("BST"    .    3600)
    ("MET"    .    3600)
    ("EET"    .    7200)
    ("JST"    .   32400)
    ("GMT+1"  .    3600) 
    ("GMT+2"  .    7200) 
    ("GMT+3"  .   10800)
    ("GMT+4"  .   14400) 
    ("GMT+5"  .   18000) 
    ("GMT+6"  .   21600)
    ("GMT+7"  .   25200) 
    ("GMT+8"  .   28800) 
    ("GMT+9"  .   32400)
    ("GMT+10" .   36000) 
    ("GMT+11" .   39600) 
    ("GMT+12" .   43200) 
    ("GMT+13" .   46800)
    ("GMT-1"  .   -3600) 
    ("GMT-2"  .   -7200) 
    ("GMT-3"  .  -10800)
    ("GMT-4"  .  -14400) 
    ("GMT-5"  .  -18000) 
    ("GMT-6"  .  -21600)
    ("GMT-7"  .  -25200) 
    ("GMT-8"  .  -28800) 
    ("GMT-9"  .  -32400)
    ("GMT-10" .  -36000) 
    ("GMT-11" .  -39600) 
    ("GMT-12" .  -43200))
  "This is taken from timezone.el, with HHMM change to seconds.")

;;; The following three functions are taken from time-date.el
;;; from gnus-5.10.6

(defalias 'comics-time-subtract
  (if (fboundp 'time-subtract)
      'time-subtract
    (lambda (t1 t2)
      (let ((borrow (< (cadr t1) (cadr t2))))
        (list (- (car t1) (car t2) (if borrow 1 0))
              (- (+ (if borrow 65536 0) (cadr t1)) (cadr t2)))))))

(defalias 'comics-time-add
  (if (fboundp 'time-add)
      'time-add
    (lambda (t1 t2)
      (let ((high (car t1))
            (low (if (consp (cdr t1)) (nth 1 t1) (cdr t1)))
            (micro (if (numberp (car-safe (cdr-safe (cdr t1))))
                       (nth 2 t1)
                     0))
            (high2 (car t2))
            (low2 (if (consp (cdr t2)) (nth 1 t2) (cdr t2)))
            (micro2 (if (numberp (car-safe (cdr-safe (cdr t2))))
                        (nth 2 t2)
                      0)))
        ;; Add
        (setq micro (+ micro micro2))
        (setq low (+ low low2))
        (setq high (+ high high2))
        
        ;; Normalize
        ;; `/' rounds towards zero while `mod' returns a positive number,
        ;; so we can't rely on (= a (+ (* 100 (/ a 100)) (mod a 100))).
        (setq low (+ low (/ micro 1000000) (if (< micro 0) -1 0)))
        (setq micro (mod micro 1000000))
        (setq high (+ high (/ low 65536) (if (< low 0) -1 0)))
        (setq low (logand low 65535))
        
        (list high low micro)))))
    
(defalias 'comics-seconds-to-time
  (if (fboundp 'seconds-to-time)
      'seconds-to-time
    (lambda (seconds)
      (list (floor seconds 65536)
            (floor (mod seconds 65536))
            (floor (* (- seconds (ffloor seconds)) 1000000))))))

(defun comics-adjusted-today (&optional arg)
  "Return the current date."
  (let ((ctime (current-time)))
    (cond
     ((numberp comics-adjust-current-time)
      ;;; Adjust current time by arg hours
      (if (< comics-adjust-current-time 0)
          (setq ctime (comics-time-subtract
                       ctime
                       (comics-hours-to-time (- comics-adjust-current-time))))
        (setq ctime (comics-time-add
                     ctime
                     (comics-hours-to-time comics-adjust-current-time))))
      (format-time-string "%Y%m%d" ctime))
     ((not arg)
      (comics-today))
     (comics-adjust-current-time
      ;; Convert from current time
      (let ((utcoffset (car (current-time-zone)))
            (argoffset (cdr (assoc arg comics-world-timezones))))
        ;; First, convert to UTC = current time - offset
        (if (< utcoffset 0)
            (setq ctime (comics-time-add
                         ctime
                         (comics-seconds-to-time (- utcoffset))))
          (setq ctime (comics-time-subtract
                       ctime
                       (comics-seconds-to-time utcoffset))))
        ;; Next, convert to arg time = UTC + arg
        (if (< argoffset 0)
            (setq ctime (comics-time-subtract
                         ctime
                         (comics-seconds-to-time (- argoffset))))
          (setq ctime (comics-time-add
                       ctime
                       (comics-seconds-to-time argoffset)))))
      (format-time-string "%Y%m%d" ctime))
     (t
      (comics-today)))))

(defun comics-today ()
  "YYYYMMDD for today."
  (comics-day-to-date 0))

(defun comics-yesterday ()
  "YYYYMMDD for today."
  (comics-day-to-date 1))

(defun comics-get-timezone-from-comic (comic-name)
  "Return the timezone associated with comic COMIC-NAME."
  (cadr (assoc (nth 3 (assoc comic-name comics-list)) 
               comics-get-comics-timezone-list)))

(defun comics-get-timezone-from-function (fn)
  "Return the timezone that is associated with FN."
  (cadr (assoc fn comics-get-comics-timezone-list)))

(defun comics-use-date (date tz)
  "Return DATE in a form usable by the functions used to get the comics."
  (cond
   ((eq date '-)
    (comics-today))
   ((not date)
    (comics-adjusted-today tz))
   (t
    date)))

(defun comics-year (date)
  "A string of the form YYYY for DATE."
  (substring date 0 4))

(defun comics-short-year (date)
  "A string of the form YY for DATE."
  (substring date 2 4))

(defun comics-month (date)
  "A string of the form MM for DATE."
  (substring date 4 6))

(defun comics-day (date)
  "A string of the form DD for DATE."
  (substring date 6 8))

(defun comics-month-name (date)
  "Return the name of the month for DATE."
  (aref calendar-month-name-array
	(- (string-to-number (comics-month date)) 1)))

(defun comics-date-to-date (date days)
  "Given DATE as YYYYMMDD, return YYYYMMDD for DAYS days from DATE."
  (let ((gtime (encode-time 0 0 12 
                            (string-to-number (comics-day date))
                            (string-to-number (comics-month date))
                            (string-to-number (comics-year date))))
        (dtime)
        (rtime1)
        (rtime2)
        (rtime))
    (cond
     ((>= days 0)
      (setq dtime  (list (/ (* days 86400) 65536)
                         (% (* days 86400) 65536)))
      (setq rtime1 (+ (car dtime) (car gtime)))
      (setq rtime2 (+ (cadr dtime) (cadr gtime)))
      (when (>= rtime2 65536)
        (setq rtime2 (- rtime2 65536))
        (setq rtime1 (+ rtime1 1)))
      (setq rtime (list rtime1 rtime2)))
     (t
      (setq dtime  (list (/ (* (- days) 86400) 65536)
                         (% (* (- days) 86400) 65536)))
      (setq rtime (if (<= (cadr dtime) (cadr gtime))
                      (list
                       (- (car gtime) (car dtime))
                       (- (cadr gtime) (cadr dtime)))
                    (list (- (car gtime) (car dtime) 1)
                          (- (+ (cadr gtime) 65536) (cadr dtime)))))))
    (format-time-string "%Y%m%d" rtime)))

;;; Some of these are from time-date.el

(defun comics-date-to-time (date)
  (encode-time 0 0 12 
               (string-to-number (comics-day date))
               (string-to-number (comics-month date))
               (string-to-number (comics-year date))))

(defun comics-date-to-day (date)
  "Return the number of days between year 1 and DATE.
DATE should be a date-time string."
  (time-to-days (comics-date-to-time date)))

(defun comics-days-between (date1 date2)
  "Return the number of days between DATE1 and DATE2.
DATE1 and DATE2 should be date-time strings."
  (- (comics-date-to-day date1) (comics-date-to-day date2)))

(defun comics-sunday-p (date)
  "Non-nil if DATE is a Sunday."
  (let* ((n (comics-days-between date "20060618"))
         (nn (% n 7)))
    (if (= nn 0)
        t
      nil)))

;;; Now, the actual fetching functions
;;; These can typically be made with 
;;;   `comics-get-file-at-url-inside-another-url' and
;;;   `comics-get-file-at-url'

;; (defun ccomics-get-comics-dot-com (name dir &optional date)
;;   "Get the comic NAME from www.comics.com."
;;   (let ((dt 
;;          (comics-use-date 
;;           date
;;           (comics-get-timezone-from-function 'comics-get-comics-dot-com))))
;;     (comics-get-file-at-url-inside-another-url
;;      (concat 
;;       "http://www.comics.com/" 
;;       dir "/" name "/archive/" name "-"
;;       dt ".html")
;;      (concat
;;       "src=\"\\(/" dir "/" name 
;;       "/archive/images/"
;;       name "[0-9]+.\\(gif\\|jpg\\)\\)\"")
;;      1
;;      "http://www.comics.com")))

(defun comics-get-comics-dot-com (name dir &optional date)
  "Get the comic NAME from www.comics.com."
  (let ((dt 
         (comics-use-date 
          date
          (comics-get-timezone-from-function 'comics-get-comics-dot-com))))
    (comics-get-file-at-url-inside-another-url
     (concat 
      "http://comics.com/" 
      name "/" (comics-year dt) "-" (comics-month dt) "-" (comics-day dt))
     "src=\"\\(http://.*.cloudfiles.rackspacecloud.com/dyn/str_strip/.*.full.\\(gif\\|jpg\\)\\)\""
     1
     "")))  ;; Remove dir
  
(defun comics-get-dilbert (&optional date)
  "Get the comic NAME from www.comics.com."
  (let ((dt 
         (comics-use-date 
          date
          (comics-get-timezone-from-function 'comics-get-comics-dot-com))))
    (comics-get-file-at-url-inside-another-url
     (concat 
      "http://dilbert.com/" 
      (comics-year dt) "-" (comics-month dt) "-" (comics-day dt))
     "value=\"\\(/dyn/str_strip/.*strip.print.\\(gif\\|jpg\\)\\)\""
     1
     "http://dilbert.com")))
  
;; (defun comics-get-comics-dot-com-latest (name dir &optional date)
;;   "Get the latest comic NAME from www.comics.com."
;;   (if (and
;;        date
;;        (not (eq date '-)))
;;       "onlylatest"
;;     (comics-get-file-at-url-inside-another-url
;;      (concat "http://www.comics.com/" dir "/" name)
;;      (concat
;;       "src=\"\\(/" dir "/" name 
;;       "/archive/images/"
;;       name "[0-9]+.\\(gif\\|jpg\\)\\)\"")
;;      1
;;      "http://www.comics.com")))

(defun comics-get-comics-dot-com-latest (name dir &optional date)
  "Get the latest comic NAME from www.comics.com."
  (if (and
       date
       (not (eq date '-)))
      "onlylatest"
    (comics-get-file-at-url-inside-another-url
     (concat 
      "http://comics.com/" name)
     "src=\"\\(http://assets.comics.com/.*full.\\(gif\\|jpg\\)\\)\""
     1
     "")))  ;; Remove dir

;(defun comics-get-kingfeatures-dot-com (name &optional date)
;  "Get the comic NAME from kingfeatures.com."
;  (let ((dt 
;         (comics-use-date 
;          date
;          (comics-get-timezone-from-function 'comics-get-ucomics-dot-com))))
;    (comics-get-file-at-url
;     (concat "http://est.rbma.com/content/"
;             name
;             "?date="
;             dt)
;     "--referer=\"http://est.rbma.com/\"")))

(defun comics-get-kingfeatures-dot-com (name &optional date)
  "Get the comic NAME from kingfeatures.com."
  (let ((dt 
         (comics-use-date 
          date
          (comics-get-timezone-from-function 'comics-get-ucomics-dot-com))))
    (setq url
     (concat "http://content.comicskingdom.net/" name "/" name "."
             (comics-year dt) (comics-month dt) (comics-day dt)
             "_large.gif"))
    (comics-get-file-at-url url)))
  

;; The comics seem to be kept at
;; http://www.phdcomics.com/comics/archive/phdMMDDYYs.gif
;; (where MMDDYY is replaced by the actual digits), but
;; they don't come out every day.

(defun comics-get-phd (&optional date)
  "Get an \"PhD\" comic."
  (if (and
       date
       (not (eq date '-)))
      "onlylatest"
    (comics-get-file-at-url-inside-another-url
     "http://www.phdcomics.com/comics.php"
     "http://www.phdcomics.com/comics/archive/.*\\(png\\|jpg\\|gif\\)"
     0)))

(defun comics-get-ucomics-dot-com (name filetype &optional date)
  "Get the comic NAME from www.ucomics.com."
  (let ((dt 
         (comics-use-date 
          date
          (comics-get-timezone-from-function 'comics-get-ucomics-dot-com))))
    (comics-get-file-at-url
     (concat "http://images.ucomics.com/comics/" 
             name
             "/"
             (comics-year dt)
             "/"
             name
             (comics-short-year dt)
             (comics-month dt)
             (comics-day dt)
             "." filetype))))

(defun comics-get-ucomics-dot-com-latest (name abbrev &optional date)
  "Get the latest comic NAME from www.ucomics.com."
  (if (and
       date
       (not (eq date '-)))
      "onlylatest"
    (comics-get-file-at-url-inside-another-url
     (concat "http://www.ucomics.com/" name)
     (concat
      "src=\"\\(http://images.ucomics.com/comics/"
      abbrev
      "/[0-9]+/"
      abbrev
      "[0-9]+.\\(gif\\|jpg\\)\\)\"")
     1)))

;; (defun comics-get-ttcomics-dot-com-latest (name abbrev &optional date)
;;   "Get the latest comic NAME from www.ucomics.com."
;;   (let ((dt 
;;          (comics-use-date 
;;           date
;;           (comics-get-timezone-from-function 'comics-get-ucomics-dot-com))))
;;     (comics-get-file-at-url-inside-another-url
;;      (concat "http://www.gocomics.com/" 
;;              name "/"
;;              (comics-year dt) "/"
;;              (comics-month dt) "/"
;;              (comics-day dt))
;;      "src=\"\\(http://imgsrv.gocomics.com/dim/.*\\)\""
;;      1)))

(defun comics-get-mutts (&optional date)
  "Get a \"Mutts\" comic."
  (let* ((dt 
          (comics-use-date 
           date
           (comics-get-timezone-from-function 
            'comics-get-mutts))))
    (comics-get-file-at-url
     (concat "http://muttscomics.com/art/images/daily/"
             (comics-month dt)
             (comics-day dt)
             (comics-short-year dt)
             ".gif"))))

(defun comics-get-comicssherpa-dot-com-latest (abbrev &optional date)
  "Get the latest comic from www.comicssherpa.com."
  (if (and
       date
       (not (eq date '-)))
       "onlylatest"
    (comics-get-file-at-url-inside-another-url
     (concat 
      "http://www.comicssherpa.com/site/feature?uc_comic=" abbrev)
     (concat
      "src=\"\\(http://images.ucomics.com/comics/"
      abbrev
      "/[0-9]+/"
      abbrev
      "[0-9]+\\.\\(gif\\|jpg\\)\\)\"")
     1)))

(defun comics-get-calvin-at-ucomics-dot-com (&optional date)
  "Get a \"Calvin and Hobbes\" comic."
  (let* ((dt 
          (comics-use-date 
           date
           (comics-get-timezone-from-function 
            'comics-get-calvin-at-ucomics-dot-com)))
         (cyear (int-to-string 
                 (- (string-to-number (comics-year dt)) 11)))
         (cshortyr (substring cyear 2 4)))
    (comics-get-file-at-url
     (concat "http://images.ucomics.com/comics/ch/" 
             cyear
             "/ch" 
             cshortyr
             (comics-month dt)
             (comics-day dt)
             ".gif"))))

(defun comics-get-snoopy-at-snoopy-co-jp (&optional date)
  "Get a \"Peanuts\" comic."
  (let* ((dt 
          (comics-use-date 
           date
           (comics-get-timezone-from-function 'comics-get-snoopy-at-snoopy-co-jp)))
         (comic
          (comics-get-file-at-url
           (concat 
            "http://www.snoopy.co.jp/cgi-bin/daily/image.cgi?d=50th&date="
            (comics-year dt)
            (comics-month dt)
            (comics-day dt))))
         (ncomic (concat comic ".gif")))
    ;; If the file is too small, it's probably an error message
    (if (< (nth 7 (file-attributes comic)) 3000)
        (progn
          (delete-file comic)
          nil)
      (rename-file comic ncomic)
      ncomic)))

(defun comics-get-girl-genius (&optional date)
  "Get a \"Girl Genius\" comic."
  (if date
      (let ((dt 
             (comics-use-date 
              date
              (comics-get-timezone-from-function 'comics-get-girl-genius))))
        (comics-get-file-at-url-inside-another-url
         (concat "http://www.girlgeniusonline.com/comic.php?date=" dt)
         "http://www.girlgeniusonline.com/ggmain/strips/ggmain.*?.jpg"
         0
         nil))
    (comics-get-file-at-url-inside-another-url
     "http://www.girlgeniusonline.com/comic.php"
     "http://www.girlgeniusonline.com/ggmain/strips/ggmain.*?.jpg"
     0
     nil)))

;    (let ((misses 0)
;          (misses-allowed 5)
;          (dt (comics-adjusted-today 
;               (comics-get-timezone-from-function 'comics-get-girl-genius))))
;    (while (and
;            (not
;             (comics-get-file-at-url-inside-another-url
;              (concat "http://www.girlgeniusonline.com/comic.php?date=" dt)
;              "http://www.girlgeniusonline.com/ggmain/strips/ggmain.*?.jpg"
;              0
;              nil))
;            (< misses misses-allowed))
;      (setq misses (1+ misses))
;      (setq dt (comics-date-to-date dt -1))))))



(defun comics-get-user-friendly (&optional date)
  "Get a \"User Friendly\" comic."
  (let ((dt 
         (comics-use-date 
          date
          (comics-get-timezone-from-function 'comics-get-user-friendly))))
    (comics-get-file-at-url-inside-another-url
     (concat 
      "http://ars.userfriendly.org/cartoons/?id="
      dt)
     (concat
      "src=\"\\(http://www.userfriendly.org/cartoons/"
      "archives/[0-9a-z]+/uf[0-9]+.gif\\)\"")
     1)))

(defun comics-get-xkcd (&optional date)
  "Get an \"Xkcd\" comic."
  (if (and
       date
       (not (eq date '-)))
      "onlylatest"
    (comics-get-file-at-url-inside-another-url
     "http://www.xkcd.com/"
     "http://imgs.xkcd.com/comics/.*\\(png\\|jpg\\)"
     0)))

(defun comics-get-shortpacked (&optional date)
  "Get a \"ShortPacked\" comic."
  (let ((dt 
         (comics-use-date 
          date
          (comics-get-timezone-from-function 'comics-get-shortpacked))))
    (comics-get-file-at-url-inside-another-url
     (concat 
      "http://www.shortpacked.com/d/" dt ".html")
      "src=\"\\(/comics/.*\\(png\\|gif\\)\\)\""
     1 "http://www.shortpacked.com")))

(defun comics-get-doctor-fun (&optional date)
  "Get a \"Doctor Fun\" comic."
  (let* ((dt 
          (comics-use-date 
           date
           (comics-get-timezone-from-function 
            'comics-get-doctor-fun)))
         (cyear (string-to-number (comics-year dt)))
         (cuseyr (if (< cyear 2000)
                     (int-to-string (- cyear 1900))
                   (int-to-string cyear))))
    (comics-get-file-at-url    
     (concat "http://www.ibiblio.org/Dave/Dr-Fun/df" 
             cuseyr
             (comics-month dt)
             "/df" 
             cuseyr
             (comics-month dt)
             (comics-day dt)
             ".jpg"))))

(defun comics-get-zippy-the-pinhead (&optional date)
  "Get a \"Zippy the Pinhead\" comic."
  (let* ((dt 
          (comics-use-date 
           date
           (comics-get-timezone-from-function 
            'comics-get-zippy-the-pinhead)))
         (cmonth (comics-month dt))
         (cyear (string-to-number (comics-year dt)))
         (cuseyr (if (< cyear 2000)
                     (int-to-string (- cyear 1900))
                   (int-to-string cyear))))
    (comics-get-file-at-url
     (concat "http://zippythepinhead.com/Merchant2/graphics/00000001/"
             (if (comics-sunday-p dt)
                 (concat "sundays/images/"
                         cmonth
                         (comics-day dt)
                         (substring cuseyr -2))
               (concat
                cuseyr
                "/images/"
                (if (and (= cyear 1995)
                         (or
                          (string= cmonth "09")
                          (string= cmonth "10")
                          (string= cmonth "11")
                          (string= cmonth "12")))
                    (concat "ZI"
                            (substring cuseyr -2)
                            cmonth
                            (comics-day dt))
                  (if (or
                       (string< "20030105" dt)
                       (< cyear 1996))
                      (concat 
                       cmonth
                       (comics-day dt)
                       (substring cuseyr -2))
                    (concat "ZIT" 
                            (substring cuseyr -1)
                            cmonth
                            (comics-day dt))))))
             ".gif"))))

;;; Now the interface functions

;; A check to see if image-type-from-file-header is defined or not.
;; If it isn't, define a simple test to see if the file might
;; be an image, namely, its size is greater than 0.
(if (not (fboundp 'image-type-from-file-header))
    (defun image-type-from-file-header (cname)
      (> (nth 7 (file-attributes cname)) 0)))

(defun comics-get-comic (comic-name date)
  "Fetch comic COMIC-NAME from DATE, or the most recent if DATE is nil."
  (setq comics-latest-url nil)
  (let* ((comic (assoc comic-name comics-list))
         (comic-file)
         (comic-maybe-file)
         (comic-file-name-with-path)
         (cdate (comics-use-date 
                 date
                 (comics-get-timezone-from-comic comic-name)))
	 (year (comics-year cdate))
	 (month (comics-month cdate))
	 (month-name (comics-month-name cdate))
	 (day (comics-day cdate))
         (comic-date
	  (concat year " " month-name " " day))
         (comic-file-long-date
	  (concat year "_" month-name "_" day))
         (comic-file-short-date
	  (concat year "_" month "_" day))
         (comic-file-name-short-date-no-sep-dir
          (concat (expand-file-name comics-dir) "/"
                  (nth 2 comic) "-" comic-file-short-date))
         (comic-file-name-long-date-no-sep-dir
          (concat (expand-file-name comics-dir) "/"
                  (nth 2 comic) "-" comic-file-long-date))
         (comic-file-name-short-date-sep-dir
          (concat (expand-file-name comics-dir) "/"
                  (nth 2 comic) "/" (nth 2 comic) "-" comic-file-short-date))
         (comic-file-name-long-date-sep-dir
          (concat (expand-file-name comics-dir) "/"
                  (nth 2 comic) "/" (nth 2 comic) "-" comic-file-long-date))
	 (comic-maybe-file
	  (catch 'exit
	    (mapcar
	     (lambda (name)
	       (mapcar (lambda (ext)
			 (let ((file (concat name ext)))
			   (if (file-exists-p file)
			       (throw 'exit file))))
		       '(".gif" ".jpg" ".png" "")))
	     (list comic-file-name-long-date-no-sep-dir
		   comic-file-name-short-date-no-sep-dir
		   comic-file-name-long-date-sep-dir
		   comic-file-name-short-date-sep-dir))
	    nil)))
    (cond
     ;; If the file exists, return the name
     ((and comic-maybe-file
           (image-type-from-file-header comic-maybe-file))
      (message (concat "Comic \"" comic-name "\" for " comic-date " already exists."))
      comic-maybe-file)
     ;; Otherwise, fetch the file
     (t
      (cond
       ((eq date '-)
        (setq comic-file
              (apply (cadr (cddr comic)) (append (cddr (cddr comic)) (list '-)))))
       (date
        (setq comic-file
              (apply (cadr (cddr comic)) (append (cddr (cddr comic)) (list cdate)))))
       (t
        (setq comic-file
              (apply (cadr (cddr comic)) (append (cddr (cddr comic)) (list nil))))))
      (cond
       ((not comic-file)
        (message 
         (concat "Unable to retrieve \"" comic-name "\" for " comic-date "."))
        nil)
       ((string= comic-file "onlylatest")
        (message
         (concat "Comics can only retrieve the latest copy of \""
                 comic-name "\"."))
        "onlylatest")
       ((not (image-type-from-file-header comic-file))
        (delete-file comic-file)
        (message 
         (concat "Unable to retrieve \"" comic-name "\" for " comic-date "."))
        nil)
       (t
        (let* ((comic-store-info
                (nth 3 (assoc comic-name comics-favorites-list)))
               (long-date 
                (if comic-store-info
                    (if (or (string-match "l" comic-store-info)
                            (string-match "L" comic-store-info))
                        t
                      nil)
                  comics-filename-long-date))
               (sep-dir
                (if comic-store-info
                    (if (or (string-match "d" comic-store-info)
                            (string-match "D" comic-store-info))
                        t
                      nil)
                  comics-use-separate-comic-directories)))
          (setq comic-file-name-with-path
                (cond 
                 ((and
                   long-date
                   sep-dir)
                  comic-file-name-long-date-sep-dir)
                 ((and
                   (not long-date)
                   sep-dir)
                  comic-file-name-short-date-sep-dir)
                 ((and
                   long-date
                   (not sep-dir))
                  comic-file-name-long-date-no-sep-dir)
                 ((and
                   (not long-date)
                   (not sep-dir))
                  comic-file-name-short-date-no-sep-dir)))
          (setq comic-file-name-with-path
                (concat comic-file-name-with-path
                        (file-name-extension comic-file t)))
          (unless (file-exists-p (file-name-directory comic-file-name-with-path))
            (make-directory (file-name-directory comic-file-name-with-path)))
          (rename-file comic-file comic-file-name-with-path)
          (message (concat "Comic \"" comic-name "\" for " comic-date " retrieved."))
          (if comics-latest-url
              (comics-url-add-url comic-name cdate comics-latest-url))
          comic-file-name-with-path)))))))

(defun comics-get-comic-url (comic-name &optional date)
  "Get the URL for comic COMIC-NAME from DATE."
  (let* ((comic (assoc comic-name comics-list))
         (cdate (if date (comics-use-date 
                          date
                          (comics-get-timezone-from-comic comic-name))
                  nil))
         (comics-urlonly t)
         (url (apply (cadr (cddr comic)) (append (cddr (cddr comic)) (list cdate)))))
    url))

(defun comics-fetch-comic (comic-name &optional day)
  "Fetch the most recent comic COMIC-NAME.
If DAY is non-nil, get the comic from DAY days previous."
  (interactive
   (list (comics-completing-read "Comic to fetch: " comics-list)
         current-prefix-arg))
  (let ((date)
        (comic-date))
    (cond
     ((or
       (not day)
       (eq day '-)
       (stringp day))
      (setq date day))
     ((numberp day)
      (setq date (comics-day-to-date day)))
     (t
      (setq date (read-string "Date (YYYYMMDD): "))))
    (comics-get-comic comic-name date)))

(defun comics-fetch-all-comics (&optional day)
  "Fetch all the most recent comics.
If DAY is non-nil, get the comics from DAY days previous."
  (interactive "P")
  (let ((date)
        (subls)
        (comic-name)
        (ls comics-categorized-list))
    (cond 
     ((or
       (not day)
       (eq day '-))
      (setq date day))
     ((numberp day)
      (setq date (comics-day-to-date day)))
     (t
      (setq date (read-string "Date (YYYYMMDD): "))))
    (while ls
      (setq subls (cdar ls))
      (while subls
        (setq comic-name (car (car subls)))
        (comics-fetch-comic comic-name date)
        (setq subls (cdr subls)))
      (setq ls (cdr ls))))
  (message "Finished fetching all current comics."))

(defun comics-fetch-favorite-comics (&optional day)
  "Fetch all the most recent comics.
If DAY is non-nil, get the comics from DAY days previous."
  (interactive "P")
  (let ((date)
        (comic-name)
        (ls comics-favorites-list))
    (cond 
     ((or
       (not day)
       (eq day '-))
      (setq date day))
     ((numberp day)
      (setq date (comics-day-to-date day)))
     (t
      (setq date (read-string "Date (YYYYMMDD): "))))
    (while ls
      (setq comic-name (car (car ls)))
      (comics-fetch-comic comic-name date)
      (setq ls (cdr ls))))
  (message "Finished downloading favorite comics."))

(defun comics-fetch-unread-favorites ()
  "Fetch unread favorite comics."
  (interactive)
  (let ((comics comics-favorites-list))
    (while comics
      (let* ((comic (caar comics))
             (date (comics-favorites-date-first-unread comic)))
        (while date
          (if (string=
               (comics-fetch-comic comic date)
               "onlylatest")
              (comics-fetch-comic comic))
          (setq date (comics-favorites-date-next comic date)))
        (setq comics (cdr comics)))))
  (message "Finished downloading unread favorites."))

(defun comics-fetch-this-comic-back (comic-name &optional arg)
  "Fetch all possible strips for comic COMIC-NAME."
  (interactive
   (list (comics-completing-read "Comic to fetch: " comics-list)
         current-prefix-arg))
  (comics-get-comic comic-name '-)
  (let ((misses 0)
        (stillok t)
        (i 1))
    (while 
        (and stillok
             (< misses comics-fetch-misses-allowed))
      (let ((cgc (comics-get-comic comic-name (comics-day-to-date i))))
        (if (string= cgc "onlylatest")
            (setq stillok nil)
          (if cgc
              (setq misses 0)
            (setq misses (1+ misses)))))
      (setq i (1+ i))
      (if (and arg
               (>= i arg))
          (setq misses comics-fetch-misses-allowed))))
  (message (concat "Finished fetching \"" comic-name "\"")))

(defun comics-fetch-favorite-comics-back (&optional arg)
  "Fetch all possible strips for the selected comics."
  (interactive "P")
  (let ((ls comics-favorites-list)
        (comic-name))
    (while ls
      (setq comic-name (car (car ls)))
      (comics-fetch-this-comic-back comic-name arg)
      (setq ls (cdr ls)))
    (message "Finished fetching all selected back comics.")))

(defun comics-read-comic (comic-name &optional day)
  "Display the most recent comic COMIC-NAME.
If DAY is non-nil display the comic from DAY days previous."
  (interactive
   (list (comics-completing-read "Comic: " comics-list)
	 current-prefix-arg))
  (setq comics-latest-url nil)
  (let* ((date)
         (comic-date)
         (datesend)
         (comic-file)
;        (comic)
;        (comic-author)
         (comic (assoc comic-name comics-list))
         (comic-author (nth 1 comic))
         (comic-file-name-with-path)
         (comic-buffer-name)
         (resize-on-open))
    (let* ((clist (assoc comic-name comics-favorites-list))
           (rsz (nth 2 clist)))
      (setq resize-on-open
            (if rsz
                rsz
              (and comics-buffer-resize
                   comics-buffer-resize-on-open
                   (executable-find comics-convert-program)
                   comics-buffer-resize-on-open))))
    (cond 
     ((not day)
      (setq date (comics-adjusted-today 
                  (comics-get-timezone-from-comic comic-name)))
      (setq datesend day))
     ((eq day '-)
      (setq date (comics-today))
      (setq datesend day))
     ((numberp day)
      (setq date (comics-day-to-date day))
      (setq datesend date))
     ((stringp day)
      (setq date day)
      (setq datesend date))
     (t
      (setq date (read-string "Date (YYYYMMDD): "))
      (setq datesend date)))
    (setq comic-date
          (concat (comics-year date) " "
                  (comics-month-name date) " "
                  (comics-day date)))
    (setq comic-buffer-name 
          (concat "*" comic-name " by " comic-author ", " comic-date "*"))
    ;; If the buffer exists, just go there
    (cond
     ((and
       (not comics-view-comics-with-external-viewer)
       (get-buffer comic-buffer-name))
      (switch-to-buffer comic-buffer-name))
     ;; Otherwise, get the file and view it
     ((and
       (setq comic-file-name-with-path
             (comics-get-comic comic-name datesend))
       (not (string= comic-file-name-with-path "onlylatest")))
      (if comics-view-comics-with-external-viewer
          (progn
            (comics-view-comic-with-external-viewer
             comic-file-name-with-path)
            (comics-favorites-add-date comic-name date))
;        (setq comic (assoc comic-name comics-list))
;        (setq comic-author (nth 1 comic))
        (switch-to-buffer comic-buffer-name)
        (add-to-list 'comics-buffer-list comic-buffer-name)
        (if comics-show-titles
            (progn
              (insert comic-name)
              (comics-facify-line 'comics-name-face)
              (if (string= comic-author "")
                  (insert "\n")
                (insert "\n" "by " comic-author "\n"))
              (insert comic-date)
              (comics-facify-line 'comics-date-face)
              (insert "\n\n")))
        (unless resize-on-open
          (insert-image-file comic-file-name-with-path))
;          (insert-image 
;           (create-image comic-file-name-with-path nil nil
;                         :ascent 99
;                         :relief 10)))
        (if comics-show-titles
            (progn
              (goto-char (point-max))
              (insert "\n")))
        (comics-buffer-mode)
        (goto-char (point-min))
        (setq comics-buffer-this-comic comic-file-name-with-path)
        (setq comics-buffer-comic-name comic-name)
        (setq comics-buffer-comic-date date)
        (setq comics-buffer-comic-url comics-latest-url)
        (comics-favorites-add-date comic-name date)
        (if resize-on-open
            (progn
              (let ((file (concat comics-temp-dir "/tmp"
                                  (file-name-nondirectory comics-buffer-this-comic))))
                (if (file-exists-p file)
                    (delete-file file)))
              (if (numberp resize-on-open)
                  (comics-buffer-resize-and-display resize-on-open nil)
                (comics-buffer-fit-comic-to-buffer))))
        (message "")))
     ((string= comic-file-name-with-path "onlylatest")
      "onlylatest"))))

(defun comics-read-comic-from-calendar ()
  "Read a comic from the current date on the calendar."
  (interactive)
  (let ((date (calendar-cursor-to-date)))
    (if (not date)
        (message "Cursor not on a date.")
      (let ((comic (comics-completing-read "Comic: " comics-list))
            (dt (format "%04d%02d%02d"
                        (nth 2 date)
                        (nth 0 date)
                        (nth 1 date))))
        (comics-read-comic comic dt)))))

(define-key calendar-mode-map "c" 'comics-read-comic-from-calendar)

(defun comics-kill-comics-buffers ()
  "Kill all the buffers used for viewing comics."
  (interactive)
  (while comics-buffer-list
    (kill-buffer (car comics-buffer-list))
    (setq comics-buffer-list (cdr comics-buffer-list))))

(defun comics-kill-comic-list-buffers ()
  "Kill all the buffers used for listing comics."
  (interactive)
  (let ((list-bufs 
         (list comics-list-buffer-name
               comics-favorites-list-buffer-name)))
  (while list-bufs
    (if (get-buffer (car list-bufs))
        (kill-buffer (car list-bufs)))
    (setq list-bufs (cdr list-bufs)))))

(defun comics-kill-comic-related-buffers ()
  "Kill all the comic related buffers.
This includes the buffers used to display the comics and the
buffers used to list the available comics."
  (comics-kill-comics-buffers)
  (comics-kill-comic-list-buffers))

(defun comics-kill-comics-buffers-query ()
  "Kill all the buffers used for viewing comics."
  (interactive)
  (if (y-or-n-p "Kill all comics buffers? ")
      (comics-kill-comics-buffers)))

(defun comics-kill-comic-related-buffers-query ()
  "Kill all the comic related buffers.
This includes the buffers used to display the comics and the
buffers used to list the available comics."
  (interactive)
  (if (y-or-n-p "Kill all comic related buffers? ")
      (comics-kill-comic-related-buffers)))

(defun comics-bury-comic-related-buffers ()
  "Bury all the comics related buffers.
This includes the buffers used to display the comics and the
buffers used to list the available comics."
  (interactive)
  (let ((list-bufs 
         (list comics-list-buffer-name
               comics-favorites-list-buffer-name))
        (cbufs comics-buffer-list))
    (while list-bufs
      (if (get-buffer (car list-bufs))
          (progn
            (set-buffer (car list-bufs))
            (bury-buffer)))
      (setq list-bufs (cdr list-bufs)))
    (while cbufs
      (set-buffer (car cbufs))
      (bury-buffer)
      (setq cbufs (cdr cbufs)))))

;;; Functions for the various buffers
(defun comics-facify-region (beg end face)
  "Put FACE on the region from BEG to END."
  (overlay-put (make-overlay beg end) 'face face))

(defun comics-facify-line (face)
  "Put FACE on the current line."
  (comics-facify-region (line-beginning-position)
                        (line-end-position) face))

;;; For reading comics, first some useful functions

(defun comics-view-comic-with-external-viewer (comic)
  "View the comic COMIC with the external viewer."
  (let ((cmd))
    (if comics-external-viewer-args
        (setq cmd 
              (append (list 'call-process 
                            comics-external-viewer
                            nil 0 nil)
                      (split-string comics-external-viewer-args)
                      (list comic)))
      (setq cmd
            (list 'call-process 
                  comics-external-viewer
                  nil 0 nil
                  comic)))
    (eval cmd)))

;;; Functions to be called from the comic buffer

(defun comics-buffer-view-comic-with-external-viewer ()
  "View the current comic with an external viewer."
  (interactive)
  (comics-view-comic-with-external-viewer comics-buffer-this-comic))

(defun comics-buffer-view-next-comic (&optional days)
  "Read the next day's comic."
  (interactive "P")
  (setq days (prefix-numeric-value days))
  (comics-read-comic comics-buffer-comic-name 
                     (comics-date-to-date comics-buffer-comic-date days)))

(defun comics-buffer-view-next-comic-skip-misses ()
  "Read the next day's comic."
  (interactive)
  (let ((comic comics-buffer-comic-name)
        (misses 0)
        (td (comics-adjusted-today 
             (comics-get-timezone-from-comic comics-buffer-comic-name)))
        (nextdate
         (comics-date-to-date comics-buffer-comic-date 1)))
    (while (and
            (or (string< nextdate td)
                (string= nextdate td))
            (not
             (comics-read-comic comic nextdate))
            (< misses comics-fetch-misses-allowed))
      (setq misses (1+ misses))
      (setq nextdate (comics-date-to-date nextdate 1)))))

(defun comics-buffer-view-previous-comic (&optional days)
  "Read the previous day's comic."
  (interactive "P")
  (setq days (prefix-numeric-value days))
  (comics-buffer-view-next-comic (- days)))

(defun comics-buffer-view-previous-comic-skip-misses ()
  "Read the previous day's comic."
  (interactive)
  (let ((comic comics-buffer-comic-name)
        (misses 0)
        (td (comics-adjusted-today 
             (comics-get-timezone-from-comic comics-buffer-comic-name)))
        (nextdate
         (comics-date-to-date comics-buffer-comic-date -1)))
    (while (and
;            (or (string< nextdate td)
;                (string= nextdate td))
            (not
             (comics-read-comic comic nextdate))
            (< misses comics-fetch-misses-allowed))
      (setq misses (1+ misses))
      (setq nextdate (comics-date-to-date nextdate -1)))))

;(defun comics-buffer-view-previous-comic-skip-misses ()
;  "Read the previous day's comic."
;  (interactive)
;  (let ((i 1)
;        (misses 0))
;    (while (and
;            (not
;             (comics-read-comic comics-buffer-comic-name 
;                                (comics-date-to-date comics-buffer-comic-date (- i))))
;            (< misses comics-fetch-misses-allowed))
;      (setq misses (1+ misses))
;      (setq i (1+ i)))))

(defun comics-buffer-view-comic-from-date ()
  "View the comic from a prompted-for date."
  (interactive)
  (let ((date (read-string "Date (YYYYMMDD): ")))
    (comics-read-comic comics-buffer-comic-name date)))

(defun comics-buffer-set-default-bookmark ()
  "Set the default bookmark for this comic to this date."
  (comics-bookmark-add-bookmark comics-buffer-comic-name
                                ""
                                comics-buffer-comic-date))

(defun comics-buffer-set-named-bookmark ()
  "Set a bookmark for this comic and this date."
  (let ((bookmark (read-string "Bookmark name: ")))
    (comics-bookmark-add-bookmark comics-buffer-comic-name
                                  bookmark
                                  comics-buffer-comic-date)))

(defun comics-buffer-set-bookmark (arg)
  "Set a bookmark for this comic and this date.
With an argument, prompt for a bookmark name, otherwise 
set the default bookmark."
  (interactive "P")
  (if arg
      (comics-buffer-set-named-bookmark)
    (comics-buffer-set-default-bookmark)))

(defun comics-buffer-goto-default-bookmark ()
  "Go to the comic for the default bookmark for this comic."
  (if (comics-bookmark-check-default-bookmark comics-buffer-comic-name)
      (comics-bookmark-goto-bookmark 
       comics-buffer-comic-name "")
    (message (concat "No default bookmark for \"" 
                     comics-buffer-comic-name
                     "\""))))

(defun comics-buffer-goto-named-bookmark ()
  "Go to a bookmark for this comic."
  (if (assoc comics-buffer-comic-name comics-bookmarks)
      (let* ((bookmark 
              (comics-completing-read 
               "Bookmark name: " 
               (cdr (assoc comics-buffer-comic-name comics-bookmarks)))))
        (comics-bookmark-goto-bookmark comics-buffer-comic-name
                                       bookmark))
    (message (concat "No bookmarks for \"" comics-buffer-comic-name "\""))))

(defun comics-buffer-goto-bookmark (arg)
  "Go to a bookmark for this comic.
With an argument, prompt for a name, otherwise the default bookmark."
  (interactive "P")
  (if arg
      (comics-buffer-goto-named-bookmark)
    (comics-buffer-goto-default-bookmark)))

(defun comics-buffer-delete-bookmark ()
  "Delete a bookmark from the comics-bookmarks."
  (interactive)
  (if (assoc comics-buffer-comic-name comics-bookmarks)
      (let ((bookmark 
             (comics-completing-read 
              (concat "Bookmark for \"" comics-buffer-comic-name "\" to delete: " )
              (cdr (assoc comics-buffer-comic-name comics-bookmarks)))))
        (comics-bookmark-delete-this-bookmark comics-buffer-comic-name bookmark))
    (message (concat "No bookmarks for \"" comics-buffer-comic-name "\""))))

(defun comics-buffer-delete-comic-file ()
  "Delete the disk file for current comic."
  (if (y-or-n-p (concat "Really delete disk file for "
                        comics-buffer-comic-name
                        " for date "
                        (comics-year comics-buffer-comic-date) " "
                        (comics-month-name comics-buffer-comic-date) " "
                        (comics-day comics-buffer-comic-date)
                        "?"))
      (delete-file comics-buffer-this-comic)))

;(defun comics-buffer-copy-comic-file (newfile)
;  "Copy the disk file for current comic."
;  (interactive "F")
;  (copy-file comics-buffer-this-comic newfile))

(defun comics-buffer-copy-comic-file ()
  "Copy the disk file for current comic."
  (interactive)
  (let* ((oldfile (file-name-nondirectory comics-buffer-this-comic))
         (newfile
          (expand-file-name
           (read-file-name "Copy comic image file to: "
            nil 
            nil
            nil
            oldfile))))
    (copy-file comics-buffer-this-comic newfile)))

(defun comics-buffer-add-comic-to-favorites (&optional arg)
  "Add the current comic to the favorites list."
  (interactive "P")
  (comics-add-favorite comics-buffer-comic-name arg))

(defun comics-buffer-remove-comic-from-favorites ()
  "Remove the comic on the current line from the favorites list."
  (interactive)
  (comics-remove-favorite comics-buffer-comic-name))

(defun comics-buffer-change-resizing-info ()
  "Change the resizing information for the current comic."
  (interactive)
  (let ((comic comics-buffer-comic-name))
    (if (not (assoc comic comics-favorites-list))
        (message (concat "\"" comic "\" is not on the favorites list."))
      (let* ((oldresize 
              (nth 2 (assoc comic comics-favorites-list)))
             (oldresizestring
              (cond
               ((eq oldresize t)
                " [Previously: fill buffer] ")
               ((numberp oldresize)
                (concat " [Previously: "
                        (number-to-string oldresize)
                        "%] "))
               (t " ")))
             (newresize
              (unless (string= comic "")
                (read-string 
                 (concat "Resize percentage"
                         oldresizestring
                         "(\"t\" for fill buffer, RET for no resizing): ")))))
        (unless (string= comic "")
          (setq newresize
                (if (string= newresize "t")
                    t
                  (if (string= newresize "")
                      nil
                    (string-to-number newresize))))
          (comics-favorites-change-resizing comic newresize))))))

(defun comics-buffer-change-storage-info ()
  "Change the storage information for the current comic."
  (interactive)
  (let ((comic-name comics-buffer-comic-name))
    (if (not (assoc comic-name comics-favorites-list))
        (message (concat "\"" comic-name "\" is not on the favorites list."))
      (let* ((storage (read-string 
                         "Enter storage information (\"D\" for separate directories, \"L\" for long dates): "))
             (comic (assoc comic-name comics-favorites-list))
             (dates (nth 1 comic))
             (rsz (nth 2 comic)))
        (setcdr comic (list dates rsz storage))
        (comics-write-favorites-file)))))


(defun comics-buffer-get-url (&optional more arg)
  "Get the URL of the current comic."
  (let* ((cmc comics-buffer-comic-name)
         (dt comics-buffer-comic-date)
         (urltry (comics-url-get-url comics-buffer-comic-name
                                     comics-buffer-comic-date))
         (url))
    (cond
     (urltry
      (setq url urltry))
     (comics-buffer-comic-url
      (setq url comics-buffer-comic-url)
      (comics-url-add-url cmc dt url))
     (arg
      (setq url (comics-get-comic-url comics-buffer-comic-name)))
     (t
      (setq url
            (comics-get-comic-url 
             comics-buffer-comic-name comics-buffer-comic-date))
      (comics-url-add-url cmc dt url)))
    (if (string= url "onlylatest")
        (setq url "Unable to get URL.")
      (if more
          (setq url (concat more url))))
    (kill-new url)
    (message url)))

(defun comics-buffer-copy-url-to-kill (&optional arg)
  "Copy the URL of the current comic to `kill-ring'."
  (interactive "P")
  (comics-buffer-get-url nil arg))

(defun comics-buffer-copy-info-to-kill ()
  "Copy various info about the current comic to `kill-ring'."
  (interactive)
  (let ((info
         (concat "\""
                 comics-buffer-comic-name 
                 "\" by "
                 (nth 1 (assoc comics-buffer-comic-name comics-list))
                 ", "
                 (comics-year comics-buffer-comic-date) 
                 " "
                 (comics-month-name comics-buffer-comic-date) 
                 " "
                 (comics-day comics-buffer-comic-date))))
    (kill-new info)
    (message info)))

(defun comics-buffer-copy-url-info-to-kill (&optional arg)
  "Copy the URL and information of the current comic to `kill-ring'."
  (interactive "P")
  (comics-buffer-get-url (concat "\""
                                 comics-buffer-comic-name 
                                 "\" by "
                                 (nth 1 (assoc comics-buffer-comic-name comics-list))
                                 ", "
                                 (comics-year comics-buffer-comic-date) 
                                 " "
                                 (comics-month-name comics-buffer-comic-date) 
                                 " "
                                 (comics-day comics-buffer-comic-date)
                                 "\n") arg))

(defun comics-buffer-catch-up ()
  "Catch up for the current comic."
  (interactive)
  (comics-catch-up-comic comics-buffer-comic-name))

;;; Now, some resizing commands, also to be called from the comics buffer

(defun comics-resize-comic (width height)
  "Resize the current comic making its size WIDTH x HEIGHT."
  (if (executable-find comics-convert-program)
      (let ((file (concat comics-temp-dir "/tmp"
                          (file-name-nondirectory comics-buffer-this-comic))))
        (unless (file-exists-p file)
          (copy-file comics-buffer-this-comic file))
        (call-process
         comics-convert-program
         nil nil nil
         file
         "-resize"
         (concat (int-to-string width) "x" (int-to-string height))
         file))
    (message (concat "Unable to find executable program: "
                     comics-convert-program))))

(defun comics-resize-comic-pct (pct)
  "Resize the current comic by PCT percent."
  (if (executable-find comics-convert-program)
      (let ((file (concat comics-temp-dir "/tmp"
                          (file-name-nondirectory comics-buffer-this-comic))))
        (unless (file-exists-p file)
          (copy-file comics-buffer-this-comic file))
        (call-process
         comics-convert-program
         nil nil nil
         file
         "-resize" (concat (int-to-string pct) "%")
         file))
    (message (concat "Unable to find executable program: "
                     comics-convert-program))))

(defun comics-buffer-resize-and-display (width height)
  "Resize the current comic and display it."
  (if (executable-find comics-convert-program)
      (let ((file (concat comics-temp-dir "/tmp"
                          (file-name-nondirectory comics-buffer-this-comic))))
        (if height
            (comics-resize-comic width height)
          (comics-resize-comic-pct width))
        (setq buffer-read-only nil)
        (save-excursion
          (goto-char (point-max))
;          (beginning-of-line)
          (forward-line -1)
          (delete-region (point) (point-max))
          (insert-image-file file)
          (goto-char (point-max))
          (insert "\n"))
        (setq buffer-read-only t))
    (message (concat "Unable to find executable program: "
                     comics-convert-program))))

;; The next function takes a routine from window-body-height in the
;; latest emacs.

(defun comics-buffer-fit-comic-to-buffer ()
  "Resize the comic so it fills up buffer."
  (interactive)
  (if (executable-find comics-convert-program)
      (let ((file (concat comics-temp-dir "/tmp"
                          (file-name-nondirectory comics-buffer-this-comic))))
        (copy-file comics-buffer-this-comic file t)
        (comics-buffer-resize-and-display
         (* (frame-char-width) (window-width))
         (* (frame-char-height) 
            (max 1 (- (window-height)
                      (if mode-line-format 1 0)
                      (if header-line-format 1 0)
                      (if comics-show-titles 4 0))))))
    (message (concat "Unable to find executable program: "
                     comics-convert-program))))

(defun comics-buffer-resize-comic (pct)
  "Resize the comic by PCT percent."
  (interactive "P")
  (if (executable-find comics-convert-program)
      (progn
        (unless pct 
          (setq pct (read-number "Percentage: ")))
        (comics-buffer-resize-and-display pct nil))
    (message (concat "Unable to find executable program: "
                     comics-convert-program))))

(defun comics-buffer-original-size ()
  "Restore the current comic to the original size."
  (interactive)
  (let ((file (concat comics-temp-dir "/tmp"
                      (file-name-nondirectory comics-buffer-this-comic))))
    (if (file-exists-p file)
        (delete-file file))
    (setq buffer-read-only nil)
    (save-excursion
      (goto-char (point-max))
;      (beginning-of-line)
      (forward-line -1)
      (delete-region (point) (point-max))
      (insert-image-file comics-buffer-this-comic)
      (goto-char (point-max))
      (insert "\n"))
    (setq buffer-read-only t)))

;;; Now, the bookmark stuff

(defun comics-bookmark-read-bookmarks ()
  "Read `comics-bookmarks' from the bookmark file."
  (when (file-exists-p (expand-file-name comics-bookmark-file))
      (save-excursion
        (set-buffer (find-file-noselect comics-bookmark-file))
        (goto-char (point-min))
        (re-search-forward "^(")
        (forward-char -1)
        (setq comics-bookmarks 
              (read (current-buffer)))
        (kill-buffer (current-buffer)))))

(defun comics-bookmark-write-bookmarks ()
  "Write the current value of `comics-bookmarks' to the bookmark file."
  (save-excursion
    (set-buffer (find-file-noselect comics-bookmark-file))
    (goto-char (point-min))
    (delete-region (point-min) (point-max))
    (insert ";;; Bookmark file for comics\n")
    (pp comics-bookmarks (current-buffer))
    (save-buffer)
    (kill-buffer (current-buffer))))

(defun comics-bookmark-add-bookmark-and-comic (comic-name bookmark date)
  "Add COMIC-NAME to `comics-bookmarks', and give it BOOKMARK and DATE."
  (setq comics-bookmarks
        (cons (list comic-name (list bookmark date)) comics-bookmarks))
  (comics-bookmark-write-bookmarks))

(defun comics-bookmark-add-bookmark-to-comic (comic-name bookmark date)
  "Add BOOKMARK and DATE to the bookmarks for COMIC-NAME."
  (let* ((comic-info (assoc comic-name comics-bookmarks))
         (comic-marks (cdr comic-info)))
    (setq comic-marks (cons (list bookmark date) comic-marks))
    (setcdr comic-info comic-marks)
    (comics-bookmark-write-bookmarks)))

(defun comics-bookmark-delete-this-bookmark (comic-name bookmark)
  "Delete BOOKMARK from the bookmarks for COMIC-NAME."
  (let* ((comic-info (assoc comic-name comics-bookmarks))
         (comic-marks (cdr comic-info)))
    (setq comic-marks (delq (assoc bookmark comic-marks) comic-marks))
    (if comic-marks
        (setcdr comic-info comic-marks)
      (setq comics-bookmarks
            (delq comic-info comics-bookmarks)))
    (comics-bookmark-write-bookmarks)))

(defun comics-bookmark-add-this-bookmark (comic-name bookmark date)
  "Add the BOOKMARK for DATE to COMIC-NAME's information."
  (if (assoc comic-name comics-bookmarks)
      (comics-bookmark-add-bookmark-to-comic comic-name bookmark date)
    (comics-bookmark-add-bookmark-and-comic comic-name bookmark date)))

(defun comics-bookmark-check-bookmark (comic-name bookmark)
  "Non-nil if COMIC-NAME already has a bookmark named BOOKMARK."
  (assoc bookmark (assoc comic-name comics-bookmarks)))

(defun comics-bookmark-check-default-bookmark (comic-name)
  "Non-nil if COMIC-NAME already has a default bookmark."
  (comics-bookmark-check-bookmark comic-name ""))

(defun comics-bookmark-add-bookmark (comic-name bookmark date)
  "Add BOOKMARK for DATE to COMIC-NAME's information.
If BOOKMARK already exists, ask first."
  (if (and
       (not (string= bookmark ""))
       (comics-bookmark-check-bookmark comic-name bookmark))
      (when (y-or-n-p (concat "Overwrite bookmark \""
                              bookmark
                              "\" for \""
                              comic-name
                              "\"? "))
        (comics-bookmark-delete-this-bookmark comic-name bookmark)
        (comics-bookmark-add-this-bookmark comic-name bookmark date))
    (if (and
         (string= bookmark "")
         (comics-bookmark-check-bookmark comic-name bookmark))
        (comics-bookmark-delete-this-bookmark comic-name bookmark))
    (comics-bookmark-add-this-bookmark comic-name bookmark date)))

(defun comics-bookmark-add-global-bookmark (bookmark comic-name date)
  "Add BOOKMARK for DATE to global information.
If BOOKMARK already exists, ask first."
  (if (and
       (not (string= bookmark ""))
       (comics-bookmark-check-bookmark 'global bookmark))
      (when (y-or-n-p (concat "Overwrite global bookmark \""
                              bookmark
                              "\"? "))
        (comics-bookmark-delete-this-bookmark 'global bookmark)
        (comics-bookmark-add-this-bookmark 'global bookmark (list comic-name date)))
    (if (and
         (string= bookmark "")
         (comics-bookmark-check-bookmark 'global bookmark))
        (comics-bookmark-delete-this-bookmark 'global bookmark))
    (comics-bookmark-add-this-bookmark 'global bookmark (list comic-name date))))

(defun comics-buffer-set-default-global-bookmark ()
  "Set the default bookmark for this comic to this date."
  (interactive)
  (comics-bookmark-add-global-bookmark 
                                ""
                                comics-buffer-comic-name
                                comics-buffer-comic-date))

(defun comics-buffer-set-named-global-bookmark ()
  "Set a bookmark for this comic and this date."
  (interactive)
  (let ((bookmark (read-string "Global bookmark name: ")))
    (comics-bookmark-add-global-bookmark 
                                  bookmark
                                  comics-buffer-comic-name
                                  comics-buffer-comic-date)))

(defun comics-buffer-set-global-bookmark (arg)
  "Set a global bookmark for the current comic.
With an arg, prompt for a name, otherwise make it the default bookmark."
  (interactive "P")
  (if arg
      (comics-buffer-set-named-global-bookmark)
    (comics-buffer-set-default-global-bookmark)))

(defun comics-bookmark-delete-this-global-bookmark (bookmark)
  "Delete BOOKMARK from the global bookmarks."
  (let* ((global-info (assoc 'global comics-bookmarks))
         (global-marks (cdr global-info)))
    (setq global-marks (delq (assoc bookmark global-marks) global-marks))
    (if global-marks
        (setcdr global-info global-marks)
      (setq comics-bookmarks
            (delq global-info comics-bookmarks)))
    (comics-bookmark-write-bookmarks)))

(defun comics-bookmark-goto-bookmark (comic-name bookmark)
  "Go to the bookmark BOOKMARK for comic COMIC-NAME."
  (let ((bookmark-info
         (assoc bookmark (cdr (assoc comic-name comics-bookmarks)))))
    (if bookmark-info
        (comics-read-comic comic-name (nth 1 bookmark-info))
      (if (string= bookmark "")
          (message (concat "No default bookmark for \"" comic-name "\""))
        (message (concat "No bookmark \"" bookmark "\" for \"" comic-name "\""))))))

(defun comics-bookmark-goto-global-bookmark (bookmark)
  "Go to bookmark BOOKMARK."
  (let ((bookmark-info
         (assoc bookmark (cdr (assoc 'global comics-bookmarks)))))
    (if bookmark-info
        (comics-read-comic (car (nth 1 bookmark-info)) (cadr (nth 1 bookmark-info)))
      (if (string= bookmark "")
          (message "No default global bookmark")
        (message (concat "No global bookmark \"" bookmark "\""))))))

(defun comics-goto-default-bookmark ()
  "Read the comic with the default bookmark."
  (let ((comic-name (comics-completing-read "Comic: " comics-bookmarks)))
    (if (comics-bookmark-check-default-bookmark comic-name)
        (comics-bookmark-goto-bookmark comic-name "")
      (message (concat "No default bookmark for \"" comic-name "\"")))))

(defun comics-goto-named-bookmark ()
  "Read the comic with the given bookmark."
  (let* ((comic-name (comics-completing-read "Comic: " comics-bookmarks))
        (bookmark (comics-completing-read (concat "Bookmark for \"" comic-name "\": ")
                                   (cdr (assoc comic-name comics-bookmarks)))))
    (comics-bookmark-goto-bookmark comic-name bookmark)))

(defun comics-goto-bookmark (arg)
  "Read the comic at a bookmark.
With an arg, prompt for a bookmark name, otherwise go to the default bookmark."
  (interactive "P")
  (if arg
      (comics-goto-named-bookmark)
    (comics-goto-default-bookmark)))

(defun comics-goto-default-global-bookmark ()
  "Read the comic with the default global bookmark."
  (comics-bookmark-goto-global-bookmark ""))

(defun comics-goto-named-global-bookmark ()
  "Read the comic with the given bookmark."
  (let ((bookmark 
         (comics-completing-read "Global bookmark: "
                                 (cdr (assoc 'global comics-bookmarks)))))
    (comics-bookmark-goto-global-bookmark bookmark)))

(defun comics-goto-global-bookmark (arg)
  "Read the comic at a global bookmark.
With an arg, prompt for a bookmark name, otherwise go to the default bookmark."
  (interactive "P")
  (if arg
      (comics-goto-named-global-bookmark)
    (comics-goto-default-global-bookmark)))

(defun comics-delete-bookmark ()
  "Delete a bookmark from the comics-bookmarks."
  (interactive)
  (let* ((comic-name (comics-completing-read "Comic: " comics-bookmarks))
         (bookmark 
          (comics-completing-read 
           (concat "Bookmark for \"" comic-name "\" to delete: ") 
           (cdr (assoc comic-name comics-bookmarks)))))
    (comics-bookmark-delete-this-bookmark comic-name bookmark)))

(defun comics-delete-global-bookmark ()
  "Delete a global bookmark."
  (interactive)
  (let ((bookmark 
          (comics-completing-read "Global bookmark: "
                                  (cdr (assoc 'global comics-bookmarks)))))
    (comics-bookmark-delete-this-global-bookmark bookmark)))

;;; Now, the favorites stuff

(defun comics-read-favorites-file ()
  "Read `comics-favorites-list' from the favorites file."
  (when (file-exists-p (expand-file-name comics-favorites-file))
      (save-excursion
        (set-buffer (find-file-noselect comics-favorites-file))
        (goto-char (point-min))
        (re-search-forward "^(")
        (forward-char -1)
        (setq comics-favorites-list
              (read (current-buffer)))
        (kill-buffer (current-buffer)))))

(defun comics-write-favorites-file ()
  "Write the current value of `comics-favorites' to the favorites file."
  (interactive)
  (save-excursion
    (set-buffer (find-file-noselect comics-favorites-file))
    (goto-char (point-min))
    (delete-region (point-min) (point-max))
    (insert ";;; Comics favorites file\n")
    (pp comics-favorites-list (current-buffer))
    (save-buffer)
    (kill-buffer (current-buffer))))

(defun comics-remove-favorite-from-list (comic-name)
  "Remove COMIC-NAME from `comics-favorites-list'."
  (if (assoc comic-name comics-favorites-list)
      (setq comics-favorites-list
            (delq (assoc comic-name comics-favorites-list) comics-favorites-list))
    (message (concat "\"" comic-name "\" not in the favorites list."))))

(defun comics-delete-favorite-from-list (comic-name)
  "Delete COMIC-NAME from `comics-favorites-list' and file."
  (comics-remove-favorite-from-list comic-name)
  (comics-write-favorites-file))

(defun comics-add-favorite-to-list (comic-name resize info &optional before odates)
  "Add COMIC-NAME to `comics-favorites-list'."
  (let* ((dates (if odates odates (comics-favorites-date-list comic-name)))
         (newelt (list comic-name 
                       (if dates dates (list (comics-yesterday)))
                       resize
                       info)))
    (if (assoc comic-name comics-favorites-list)
        (comics-remove-favorite-from-list comic-name))
    (if comics-favorites-alphabetical
        (progn
          (setq comics-favorites-list
                (cons newelt comics-favorites-list))
          (comics-order-favorites))
      (if (not before)
          (setq comics-favorites-list
                (append comics-favorites-list
                        (list newelt)))
        (if (equal before (car (car comics-favorites-list)))
            (setq comics-favorites-list 
                  (cons newelt comics-favorites-list))
          (let ((com (assoc before comics-favorites-list)))
            (if (not com)
                (setq comics-favorites-list 
                      (append comics-favorites-list (list newelt)))
              (let* ((n (length comics-favorites-list))
                     (nn (length (memq com comics-favorites-list)))
                     (m (- n nn 1))
                     (tl (nthcdr m comics-favorites-list)))
                (setcdr tl (cons newelt (cdr tl)))))))))
    (comics-write-favorites-file)))

(defun comics-string-lessp (str1 str2)
  "Compare string STR1 and STR2, ignoring beginning \"The\" and \"A\"."
  (if (and (string-match "The " str1)
           (= (string-match "The " str1) 0))
      (setq str1 (substring str1 4)))
  (if (and (string-match "The " str2)
           (= (string-match "The " str2) 0))
      (setq str2 (substring str2 4)))
  (if (and (string-match "A " str1)
           (= (string-match "A " str1) 0))
      (setq str1 (substring str1 2)))
  (if (and (string-match "A " str2)
           (= (string-match "A " str2) 0))
      (setq str2 (substring str2 2)))
  (string< str1 str2))

;;; From bookmark.el
(defun comics-order-favorites ()
  "Put the comics in `comics-favorites-list' in alphabetical order."
  (setq comics-favorites-list
        (sort (copy-alist comics-favorites-list)
                  (function
                   (lambda (x y) (comics-string-lessp (car x) (car y)))))))

(defun comics-alphabetize-favorites ()
  (interactive)
  (comics-order-favorites)
  (comics-write-favorites-file)
  (comics-favorites-list-refresh-buffer))


(defun comics-add-favorite (comic &optional arg)
  "Add COMIC to the favorites list."
  (interactive (list (comics-completing-read 
                      "Comic to add to favorites: "
                      comics-list)
                     current-prefix-arg))
  (if (not (string= comic ""))
    (if (assoc comic comics-favorites-list)
        (message (concat "\"" comic "\" is already on the favorites list."))
      (let ((info 
             (if comics-get-storage-info
                 (read-string 
                  "Enter storage info: (D for separate directory, L for long date format): ")
               nil))
            (resize
             (if arg
                 (read-string
                  "Resize percentage (\"t\" for fill-buffer, RET for no resizing): ")
               nil)))
        (if resize
            (setq resize
                  (if (string= resize "t")
                      t
                    (if (string= resize "")
                      nil
                    (string-to-number resize)))))
      (if (string= info "t") 
          (setq info nil))
      (comics-add-favorite-to-list comic resize info)
      (when (get-buffer comics-favorites-list-buffer-name)
        (set-buffer comics-favorites-list-buffer-name)
        (comics-favorites-list-refresh-buffer))
      (when (get-buffer comics-list-buffer-name)
        (save-excursion
          (set-buffer comics-list-buffer-name)
          (save-excursion
            (goto-char (point-min))
            (when (search-forward (concat "  " comic "\n"))
              (forward-line -1)
              (comics-facify-line 'comics-favorites-face)))))))))
  
(defun comics-remove-favorite (comic)
  "Remove comic COMIC from the favorites list."
  (interactive (list (comics-completing-read "Comic to remove from favorites: "
                                             comics-favorites-list)))
  (if (not (assoc comic comics-favorites-list))
      (message (concat "\"" comic "\" is not on the favorites list."))
    (when (y-or-n-p (concat "Really remove " comic " from favorites? "))
      (comics-delete-favorite-from-list comic)
      (when (get-buffer comics-favorites-list-buffer-name)
        (set-buffer comics-favorites-list-buffer-name)
        (comics-favorites-list-refresh-buffer))
      (when (get-buffer comics-list-buffer-name)
        (save-excursion
          (set-buffer comics-list-buffer-name)
          (save-excursion
            (goto-char (point-min))
            (when (search-forward (concat "  " comic "\n"))
              (forward-line -1)
              (remove-overlays (line-beginning-position) 
                               (line-end-position)
                               'face 'comics-favorites-face))))))))

;;; Some functions for keeping track of what favorites have been read.

(defun comics-favorites-date-list (comic)
  "Return the list of dates read for comic COMIC.
nil will mean yesterday."
  (let* ((comicinfo (assoc comic comics-favorites-list))
         (dlist (nth 1 comicinfo)))
    (if comicinfo
        (if dlist
            (nth 1 comicinfo)
          (list (comics-yesterday)))
      nil)))

(defun comics-favorites-date-next (comic date)
  "Return the first unread date for COMIC after DATE.
Return nil if no unread date."
  (let ((dlist (comics-favorites-date-list comic)))
    (when dlist
      (setq date (comics-date-to-date date 1))
      (while (member date dlist)
        (setq date (comics-date-to-date date 1)))
      (if (string< (comics-today) date)
          nil
        date))))

(defun comics-favorites-date-first-unread (comic)
  "Return the first unread date for COMIC."
  (let* ((dlist (comics-favorites-date-list comic))
         (date (car dlist)))
    (when dlist
      (setq date (comics-date-to-date date 1))
      (while (member date dlist)
        (setq date (comics-date-to-date date 1)))
      (if (string< (comics-today) date)
          nil
        date))))

(defun comics-favorites-order-dates (dates)
  "Put the DATES list in order."
  (sort dates 'string<))

(defun comics-favorites-add-date (comic-name date)
  "Add DATE to date list for comic COMIC-NAME."
  (let* ((comic (assoc comic-name comics-favorites-list))
         (dates (nth 1 comic)))
    (when comic
      (unless (or
               (member date dates)
               (and dates
                    (string< date (car dates))))
        (setq dates (comics-favorites-order-dates (cons date dates)))
        (setcdr comic (cons dates (cdr (cdr comic))))
        (comics-write-favorites-file)))))

(defun comics-catch-up-comic (comic-name)
  "Replace date list for comic COMIC-NAME by a list containing only today."
  (let ((comic (assoc comic-name comics-favorites-list)))
    (if (not comic)
        (message (concat "\"" comic-name "\" is not on the favorites list."))
      (setcdr comic (cons (list (comics-today)) (cdr (cdr comic))))
      (comics-write-favorites-file))))

(defun comics-catch-up-comics ()
  "Replace date list for comics by a list containing only today."
  (let ((clist comics-favorites-list))
    (while clist
      (let ((comic (car clist)))
        (setcdr comic (cons (list (comics-today)) (cdr (cdr comic)))))
      (setq clist (cdr clist)))
    (comics-write-favorites-file)))

(defun comics-favorites-change-date (comic-name date)
  "Change the date that COMICS-NAME has stored to DATE."
  (if comic-name
      (let* ((comic (assoc comic-name comics-favorites-list))
             (info (cdr comic)))
        (when comic
          (setcdr comic (cons date (cdr (cdr comic))))
          (comics-write-favorites-file)))))

(defun comics-favorites-comic-name ()
  "Get the name of the comic on the current line."
  (if (>= (point) comics-list-beg-point)
      (let ((comic (buffer-substring-no-properties
                    (line-beginning-position)
                    (line-end-position))))
        (if (string= comic "")
            nil
          comic))))

(defun comics-favorites-change-resizing (comic-name sizing)
  "Change the resizing information for COMICS-NAME."
  (if (and comic-name (not (string= comic-name "")))
      (let* ((comic (assoc comic-name comics-favorites-list))
             (info (cdr comic)))
        (when comic
          (setcdr info (cons sizing (cdr (cdr info))))
          (comics-write-favorites-file)))))

(defun comics-favorites-change-resizing-info ()
  "Change the resizing information for the current comic."
  (interactive)
  (if (>= (point) comics-list-beg-point)
      (let ((comic (comics-favorites-comic-name)))
        (if comic
            (if (not (assoc comic comics-favorites-list))
                (message (concat "\"" comic "\" is not on the favorites list."))
              (let* ((oldresize 
                      (nth 2 (assoc comic comics-favorites-list)))
                     (oldresizestring
                      (cond
                       ((eq oldresize t)
                        " [Previously: fill buffer] ")
                       ((numberp oldresize)
                        (concat " [Previously: "
                                (number-to-string oldresize)
                                "%] "))
                       (t " ")))
                     (newresize
                      (unless (string= comic "")
                        (read-string 
                         (concat "Resize percentage"
                                 oldresizestring
                                 "(\"t\" for fill buffer, RET for no resizing): ")))))
                (unless (string= comic "")
                  (setq newresize
                        (if (string= newresize "t")
                            t
                          (if (string= newresize "")
                              nil
                            (string-to-number newresize))))
                  (comics-favorites-change-resizing comic newresize))))))))

(defun comics-favorites-change-storage-info ()
  "Change the storage information for the current comic."
  (interactive)
  (if (>= (point) comics-list-beg-point)
      (let ((comic-name (comics-favorites-comic-name)))
        (if comic-name
            (if (not (assoc comic-name comics-favorites-list))
                (message (concat "\"" comic-name "\" is not on the favorites list."))
              (let* ((storage (read-string 
                                 "Enter storage information (\"D\" for separate directories, \"L\" for long dates): "))
                     (comic (assoc comic-name comics-favorites-list))
                     (dates (nth 1 comic))
                     (rsz (nth 2 comic)))
                (setcdr comic (list dates rsz storage))
                (comics-write-favorites-file)))))))
    
(defun comics-favorites-catch-up-comic ()
  (interactive)
  (let ((comic (comics-favorites-comic-name)))
    (if (and
         comic
         (y-or-n-p (concat "Really catch up on \"" comic "\"? ")))
        (comics-catch-up-comic comic))))

(defun comics-favorites-catch-up-all ()
  (interactive)
  (if (and
       comics-favorites-list
       (y-or-n-p "Really catch up on all comics? "))
      (comics-catch-up-comics)))

(defun comics-favorites-list-read-first-unread-comic ()
  "Read the first unread comic from the strip on the current line."
  (interactive)
  (comics-read-first-unread-favorite-comic (comics-favorites-comic-name)))

(defun comics-read-first-unread-favorite-comic (comic)
  "Read the first unread favorite comic COMIC from the strip on the current line."
  (if comic
      (if (not (assoc comic comics-favorites-list))
          (message (concat "\"" comic "\" is not on the favorites list."))
        (let* ((buf (current-buffer))
               (date (comics-favorites-date-first-unread comic))
               (rn (if date (comics-read-comic comic date) nil)))
          (while (and date (or (not rn) (string= rn "onlylatest")))
            (if (string= rn "onlylatest")
                (progn
                  (comics-catch-up-comic comic)
                  (comics-read-comic comic)
                  (setq rn t))
              (setq date (comics-favorites-date-next comic date))
              (if date
                  (setq rn (comics-read-comic comic date)))))
          (when (not date)
            (set-buffer buf)
            (forward-line 1))))))

(defun comics-buffer-read-next-unread-favorite ()
  "Read the next unread comic in the favorites list."
  (interactive)
  (let* ((comic comics-buffer-comic-name)
         (date (comics-favorites-date-next
                comics-buffer-comic-name
                comics-buffer-comic-date))
         (rn (if date (comics-read-comic comic date) nil)))
    (while (and date (or (not rn) (string= rn "onlylatest")))
      (if (string= rn "onlylatest")
          (progn
            (comics-catch-up-comic comic)
            (comics-read-comic comic)
            (setq date nil))
        (setq date (comics-favorites-date-next comic date))
        (if date
            (setq rn (comics-read-comic comic date)))))
    (if (not date)
        (progn
          (comics-goto-comics-favorites-list)
          (goto-char (point-min))
          (re-search-forward comic)
          (forward-line 1)))))

;;; Functions for keeping track of urls

(defun comics-url-read-urls ()
  "Read `comics-urls' from the url file."
  (when (file-exists-p (expand-file-name comics-url-file))
      (save-excursion
        (set-buffer (find-file-noselect comics-url-file))
        (goto-char (point-min))
        (re-search-forward "^(")
        (forward-char -1)
        (setq comics-urls 
              (read (current-buffer)))
        (kill-buffer (current-buffer)))))

(defun comics-url-write-urls ()
  "Write the current value of `comics-urls' to the url file."
  (interactive)
  (save-excursion
    (set-buffer (find-file-noselect comics-url-file))
    (goto-char (point-min))
    (delete-region (point-min) (point-max))
    (insert ";;; Url file for comics\n")
    (pp comics-urls (current-buffer))
    (save-buffer)
    (kill-buffer (current-buffer))))

(defun comics-url-delete-date (comic-name date)
  (let* ((comic-info (assoc comic-name comics-urls))
         (comic-dates (cdr comic-info)))
    (setq comic-dates (delq (assoc date comic-dates) comic-dates))
    (if comic-info
        (setcdr comic-info comic-dates))))

(defun comics-url-add-url (comic-name date url)
  "Add the url for COMIC-NAME on DATE."
  (if comics-save-urls
      (let* ((comic-info (assoc comic-name comics-urls))
             (comic-dates (cdr comic-info)))
        (if comic-info
            (progn 
              (comics-url-delete-date comic-name date)
              (setq comic-dates 
                    (cons (list date url) comic-dates))
              (setcdr comic-info comic-dates))
          (setq comics-urls
                (cons (list comic-name (list date url)) comics-urls)))
        (comics-url-write-urls))))

(defun comics-url-get-url (comic-name date)
  "Get the url for comic COMIC-NAME."
  (let ((url-info
         (assoc date (cdr (assoc comic-name comics-urls)))))
    (nth 1 url-info)))

;;; The comics list buffers

;;; Functions for list buffers

(defun comics-list-comic-name ()
  "Return the name of the comic on the current line.
nil if no comic."
  (let ((beg nil)
        (end))
    (when (>= (point) comics-list-beg-point)
      (save-excursion
        (beginning-of-line)
        (when (looking-at "^  ")
          (beginning-of-line-text)
          (setq beg (point))
          (end-of-line)
          (setq end (point))))
      (if beg
          (buffer-substring-no-properties beg end)))))

(defun comics-list-read-comic (arg)
  "Read the comic on the current line."
  (interactive "P")
  (when (>= (point) comics-list-beg-point)
    (let ((comic (comics-list-comic-name)))
      (if comic
          (comics-read-comic comic arg)
        (comics-list-toggle-category)))))

(defun comics-list-read-comic-date ()
  "Read the comic on the current line from the prompted for date."
  (interactive)
  (let ((comic (comics-list-comic-name)))
    (if comic
        (let ((date (read-string "Date (YYYYMMDD): ")))
          (comics-read-comic comic date)))))

(defun comics-list-fetch-comic (arg)
  "Fetch the comic on the current line."
  (interactive "P")
  (when (>= (point) comics-list-beg-point)
    (let ((comic (comics-list-comic-name)))
      (if comic
          (comics-fetch-comic comic arg)
        (comics-list-toggle-category)))))

(defun comics-list-fetch-this-comic-back (arg)
  "Fetch the comic on the current line, including older strips."
  (interactive "P")
  (let ((comic (comics-list-comic-name)))
    (if comic
        (comics-fetch-this-comic-back comic arg))))

(defun comics-list-fetch-comic-date ()
  "Fetch the comic on the current line from the prompted for date."
  (interactive)
  (let ((comic (comics-list-comic-name)))
    (if comic
        (let ((date (read-string "Date (YYYYMMDD): ")))
          (comics-fetch-comic comic date)))))

(defun comics-list-catch-up-comic ()
  (interactive)
  (when (>= (point) comics-list-beg-point)
    (let ((name (comics-list-comic-name)))
      (if (and
           name
           (not (assoc name comics-favorites-list)))
          (message (concat "\"" name "\" not on the favorites list."))
        (if (and
             name
             (y-or-n-p (concat "Really catch up on \"" name "\"? ")))
            (comics-catch-up-comic name))))))

(defun comics-list-read-first-unread-comic ()
  "Read the first unread comic from the strip on the current line."
  (interactive)
  (when (>= (point) comics-list-beg-point)
    (comics-read-first-unread-favorite-comic
     (comics-list-comic-name))))

(defun comics-list-change-resizing-info ()
  "Change the resizing information for the current comic."
  (interactive)
  (let ((comic (comics-list-comic-name)))
    (if comic
        (if (not (assoc comic comics-favorites-list))
            (message (concat "\"" comic "\" is not on the favorites list."))
          (let* ((oldresize 
                  (nth 2 (assoc comic comics-favorites-list)))
                 (oldresizestring
                  (cond
                   ((eq oldresize t)
                    " [Previously: fill buffer] ")
                   ((numberp oldresize)
                    (concat " [Previously: "
                            (number-to-string oldresize)
                            "%] "))
                   (t " ")))
                 (newresize
                  (unless (string= comic "")
                    (read-string 
                     (concat "Resize percentage"
                             oldresizestring
                             "(\"t\" for fill buffer, RET for no resizing): ")))))
            (unless (string= comic "")
              (setq newresize
                    (if (string= newresize "t")
                        t
                      (if (string= newresize "")
                          nil
                        (string-to-number newresize))))
              (comics-favorites-change-resizing comic newresize)))))))

(defun comics-list-change-storage-info ()
  "Change the storage information for the current comic."
  (interactive)
  (let ((comic-name (comics-list-comic-name)))
    (if comic-name
        (if (not (assoc comic-name comics-favorites-list))
            (message (concat "\"" comic-name "\" is not on the favorites list."))
          (let* ((storage (read-string 
                             "Enter storage information (\"D\" for separate directories, \"L\" for long dates): "))
                 (comic (assoc comic-name comics-favorites-list))
                 (dates (nth 1 comic))
                 (rsz (nth 2 comic)))
            (when (and (not (string= comic-name "")) comic)
              (setcdr comic (list dates rsz storage))
              (comics-write-favorites-file)))))))

(defun comics-list-expand-category ()
  "Show all the comics in the current category."
  (let* ((cat (buffer-substring-no-properties (line-beginning-position)
                                              (line-end-position)))
         (ls (cdr (assoc cat comics-categorized-list))))
    (setq buffer-read-only nil)
    (save-excursion
      (end-of-line)
      (while ls
        (let ((comic (caar ls)))
          (insert "\n  ")
          (insert comic)
          (if (assoc comic comics-favorites-list)
              (comics-facify-line 'comics-favorites-face))
          (setq ls (cdr ls)))))
    (setq buffer-read-only t)))

(defun comics-list-expand-all-categories ()
  "Show all the comics."
  (interactive)
  (let ((already-expanded nil))
    (save-excursion
      (goto-char comics-list-beg-point)
      (while (re-search-forward "^[^ ]" nil t)
        (save-excursion
          (forward-line 1)
          (setq already-expanded (looking-at "^ ")))
        (unless already-expanded
          (comics-list-expand-category))))))

(defun comics-list-hide-category ()
  "Hide all the comics in the current category."
  (let ((pt))
    (setq buffer-read-only nil)
    (save-excursion
      (forward-line 1)
      (setq pt (point))
      (re-search-forward "^[^ ]" nil 1)
      (forward-char -1)
      (delete-region pt (point)))
    (setq buffer-read-only t)))

(defun comics-list-hide-all-categories ()
  "Hide all the comics."
  (interactive)
  (let ((already-expanded nil))
    (save-excursion
      (goto-char comics-list-beg-point)
      (while (re-search-forward "^[^ ]" nil t)
        (save-excursion
          (forward-line 1)
          (setq already-expanded (looking-at "^ ")))
        (if already-expanded
          (comics-list-hide-category))))))

(defun comics-list-toggle-category ()
  "Toggle the display of the comics in the current category."
  (interactive)
  (when (>= (point) comics-list-beg-point)
    (let ((hide nil))
      ;; Find the beginning of the category
      (unless (looking-at "^[^ ]")
        (re-search-backward "^[^ ]"))
      ;; Determine if the category is expanded or not
      (save-excursion
        (forward-line 1)
        (if (looking-at "^ ")
            (setq hide t)))
      (if hide
          (comics-list-hide-category)
        (comics-list-expand-category)))))

(defun comics-list-goto-default-bookmark ()
  "Read the comic at the default bookmark."
  (let ((beg nil)
        (end)
        (comic-name nil))
    (when (>= (point) comics-list-beg-point)
      (save-excursion
        (beginning-of-line)
        (when (looking-at "^  ")
          (beginning-of-line-text)
          (setq beg (point))
          (end-of-line)
          (setq end (point))
          (setq comic-name (buffer-substring-no-properties beg end))))
      (when comic-name
        (if (comics-bookmark-check-default-bookmark comic-name)
            (comics-bookmark-goto-bookmark comic-name "")
          (message (concat "No default bookmark for \"" comic-name "\"")))))))

(defun comics-list-goto-named-bookmark ()
  "Read the comic at the given bookmark."
  (let ((beg nil)
        (end)
        (comic-name nil)
        (bookmark))
    (when (>= (point) comics-list-beg-point)
      (save-excursion
        (beginning-of-line)
        (when (looking-at "^  ")
          (beginning-of-line-text)
          (setq beg (point))
          (end-of-line)
          (setq end (point))
          (setq comic-name (buffer-substring-no-properties beg end)))))
    (when comic-name
      (if (assoc comic-name comics-bookmarks)
          (progn
            (setq bookmark 
                  (comics-completing-read (concat "Bookmark for \"" comic-name "\": ") 
                                          (cdr (assoc comic-name comics-bookmarks))))
            (comics-bookmark-goto-bookmark comic-name bookmark))
        (message (concat "No bookmarks for \"" comic-name "\""))))))

(defun comics-list-goto-bookmark (arg)
  "Go to the comic at a bookmark.
With an arg, prompt for a name, otherwise use the default bookmark."
  (interactive "P")
  (if arg
      (comics-list-goto-named-bookmark)
    (comics-list-goto-default-bookmark)))

(defun comics-list-delete-bookmark ()
  "Delete the bookmark."
  (interactive)
  (let ((beg nil)
        (end)
        (comic-name)
        (bookmark)
        (def nil))
    (when (>= (point) comics-list-beg-point)
      (save-excursion
        (beginning-of-line)
        (when (looking-at "^  ")
          (beginning-of-line-text)
          (setq beg (point))
          (end-of-line)
          (setq end (point))))
      (setq def (buffer-substring-no-properties beg end)))
    (setq comic-name
          (comics-completing-read "Comic: " comics-bookmarks def))
    (setq bookmark 
          (comics-completing-read 
           (concat "Bookmark for \""  comic-name "\" to delete: ")
           (cdr (assoc comic-name comics-bookmarks))))
    (comics-bookmark-delete-this-bookmark comic-name bookmark)))

(defun comics-list-add-comic-to-favorites (&optional arg)
  "Add the comic on the current line to the favorites list."
  (interactive)
  (let ((comic (comics-list-comic-name)))
    (if comic
        (if (assoc comic comics-favorites-list)
            (message (concat "\"" comic "\" is already on the favorites list."))
          (comics-add-favorite comic arg)))))

(defun comics-list-remove-comic-from-favorites ()
  "Remove the comic on the current line from the favorites list."
  (interactive)
  (let ((comic (comics-list-comic-name)))
    (if comic
        (if (not (assoc comic comics-favorites-list))
            (message (concat "\"" comic "\" is not on the favorites list."))
          (comics-remove-favorite comic)))))

;;; The keymap

(defvar comics-buffer-keymap nil
  "The keymap for the comics buffers.")

(if comics-buffer-keymap
    nil
  (let ((map (make-sparse-keymap)))
    (define-key map "q" 'comics-bury-comic-related-buffers)
    (define-key map " " 'comics-buffer-read-next-unread-favorite)
    (define-key map "k" 'comics-kill-comics-buffers-query)
    (define-key map "K" 'comics-kill-comic-related-buffers-query)
    (define-key map "l" 'comics-goto-comics-favorites-list)
    (define-key map "L" 'comics-goto-comics-list)
    (define-key map "c" 'comics-buffer-catch-up)
    (define-key map "C" 'comics-favorites-catch-up-all)
    (define-key map "u" 'comics-buffer-copy-url-to-kill)
    (define-key map "U" 'comics-buffer-copy-url-info-to-kill)
    (define-key map "D" 'comics-buffer-copy-comic-file)
    (define-key map "i" 'comics-buffer-copy-info-to-kill)
    (define-key map "\C-c\C-v" 'comics-buffer-view-comic-with-external-viewer)
    (define-key map "n" 'comics-buffer-view-next-comic)
    (define-key map "N" 'comics-buffer-view-next-comic-skip-misses)
    (define-key map "\C-m" 'comics-buffer-view-next-comic)
    (define-key map "p" 'comics-buffer-view-previous-comic)
    (define-key map "P" 'comics-buffer-view-previous-comic-skip-misses)
    (define-key map [backspace] 'comics-buffer-view-previous-comic)
    (define-key map "d" 'comics-buffer-view-comic-from-date)
    (define-key map "g" 'comics-buffer-goto-bookmark)
    (define-key map "G" 'comics-goto-global-bookmark)
    (define-key map "b" 'comics-buffer-set-bookmark)
    (define-key map "B" 'comics-buffer-set-global-bookmark)
    (define-key map "\C-c\C-b" 'comics-buffer-delete-bookmark)
    (define-key map "\C-c\C-g" 'comics-delete-global-bookmark)
    (define-key map "\C-c\C-f" 'comics-fetch-favorite-comics)
    (define-key map "\C-c\C-u" 'comics-fetch-unread-favorites)
    (define-key map [delete] 'comics-buffer-delete-comic-file)
    (define-key map "f" 'comics-buffer-add-comic-to-favorites)
    (define-key map "\C-c\C-k" 'comics-buffer-remove-comic-from-favorites)
    (define-key map "\C-c\C-r" 'comics-buffer-change-resizing-info)
    (define-key map "\C-c\C-s" 'comics-buffer-change-storage-info)
    (when comics-buffer-resize
      (define-key map "R" 'comics-buffer-resize-comic)
      (define-key map "F" 'comics-buffer-fit-comic-to-buffer)
      (define-key map "O" 'comics-buffer-original-size))
    (setq comics-buffer-keymap map)))

(defun comics-buffer-mode ()
  "In the buffer displaying the comic, the following commands are available:

Viewing:
\\[comics-buffer-view-next-comic]  
  View the comic from the next day
  (with argument N, view the comic from N days forward)
\\[comics-buffer-view-next-comic-skip-misses]  
  View the comic from the next day, skipping days with missing comics
\\[comics-buffer-view-previous-comic]
  View the comic from the previous day
  (with argument N, view the comic from N days backward)
\\[comics-buffer-view-previous-comic-skip-misses]  
  View the comic from the previous day, skipping days with missing comics
\\[comics-buffer-view-comic-from-date]
  View the comic from a prompted-for date
\\[comics-buffer-view-comic-with-external-viewer]
  View the comic in an external viewer

Resizing:
\\[comics-buffer-fit-comic-to-buffer]
  Fit the comic to fill the buffer
\\[comics-buffer-resize-comic]
  Resize the comic to a percentage of its current size
  (The percentage can be given as a prefix, or it will
   be prompted for.)
\\[comics-buffer-original-size]
  Restore the comic to its original size.

Bookmarks:
\\[comics-buffer-set-bookmark]
  Set this comic as the default bookmark
  With an argument, prompt for a name for the bookmark
\\[comics-buffer-set-global-bookmark]
  Set this comic as the default global bookmark
  With an argument, prompt for a name for the bookmark
\\[comics-buffer-goto-bookmark]
  View the comic at the default bookmark
  With an argument, prompt for a bookmark name
\\[comics-goto-global-bookmark]
  View the comic at the default global bookmark
  With an argument, prompt for a bookmark name
\\[comics-buffer-delete-bookmark]
  Delete a bookmark
\\[comics-delete-global-bookmark]
  Delete a global bookmark

Favorites:
\\[comics-buffer-add-comic-to-favorites]
  Add the current comic to the favorites list
\\[comics-buffer-remove-comic-from-favorites]
  Remove the current comic from the favorites list
\\[comics-buffer-read-next-unread-favorite]
  Read the next unread comic from the favorites list.
\\[comics-buffer-catch-up]
  Mark the current comic as all read.
\\[comics-favorites-catch-up-all]
  Mark all comics as all read.
\\[comics-buffer-change-resizing-info]
  Change the default resizing information for the current comic.
\\[comics-fetch-favorite-comics]
  Download all of today's favorite comics.
\\[comics-fetch-unread-favorites]
  Download all unread favorite comics.

Comic information:
\\[comics-buffer-copy-url-to-kill]
  Copy the URL of the comic to the kill ring.
\\[comics-buffer-copy-info-to-kill]
  Copy the information (title, author, date) of the comic to the kill ring.
\\[comics-buffer-copy-url-info-to-kill]
  Copy the information and url to the kill ring.

Leaving comics:
\\[comics-bury-comic-related-buffers]
  Bury the buffer.
\\[comics-kill-comics-buffers-query]
  Kill all comics buffers.
\\[comics-kill-comic-related-buffers-query]
  Kill all comic related buffers.

Misc:
\\[comics-goto-comics-favorites-list]
  Switch to the buffer containing the list of favorite comics.
  Create the buffer if necessary.
\\[comics-goto-comics-list]
  Switch to the buffer containing the list of comics.
  Create the buffer if necessary.
\\[comics-buffer-delete-comic-file]
  Delete the comic file.
\\[comics-buffer-copy-comic-file]
  Copy (Duplicate) the comic file to a prompted-for file.

\\{comics-buffer-keymap}"
  (kill-all-local-variables)
  (use-local-map comics-buffer-keymap)
  (setq mode-name "Comic buffer")
  (setq major-mode 'comics-buffer-mode)
  (setq buffer-read-only t)
;  (add-hook 'kill-buffer-hook
;            'comics-write-favorites-file)
  (run-hooks 'comics-buffer-hook))

;;; Now, setting things up
(defvar comics-list-current-line-overlay nil)
(make-variable-buffer-local 'comics-list-current-line-overlay)

(defun comics-list-post-command-hook ()
  "A function to move the overlay indicating the current line."
  (if (< (point) comics-list-beg-point)
      (move-overlay comics-list-current-line-overlay
                    (line-beginning-position)
                    (line-beginning-position)
                    (get-buffer comics-list-buffer-name))
    (move-overlay comics-list-current-line-overlay
                  (line-beginning-position)
                  (line-end-position)
                  (get-buffer comics-list-buffer-name))))

;;; The texts
(defvar comics-list-prelude
"COMICS LIST
===========
"
"A string to put at the beginning of a Comics list buffer.")

(defvar  comics-list-instructions 
"Instructions:
The comics list consists of categories (not indented) and
comics (indented).  Favorite comics are bolded.
Displaying the list:
TAB      Toggle the display of the comics in the current category.
C-cC-e   Expand all the categories.
C-cC-h   Unexpand all the categories.

Viewing the comics:
r or RET Retrieve and display the comic on the current line.
         (With a numeric argument n, get the comic from n 
         days ago.  With a non-numeric argument, such as C-u RET,
         get the comic from a prompted for date.)
         If the point is on a category line, toggle the display of
         the comics in the category.
R or F   Like \"r\", but doesn't display the comic, only fetches it.
d        Read the comic on the current line at a prompted for date.
D        Like \"d\", but doesn't display the comic, only fetches it.
C-cC-d   Fetch this comic back (current and older strips).
g        Go to the default bookmark.
         With an argument, prompt for a bookmark name
G        Go to a global bookmark.
         With an argument, prompt for a bookmark name
C-cC-b   Delete a bookmark.
C-cC-g   Delete a global bookmark.

For favorite comics:
f        Add current comic to favorite comics list.
l        Go to a list of favorite comics.
L        Go to a list of all comics.
C-cC-k   Remove current comic from favorite comics list.
SPC      Read the first unread comic of the current strip.
c        Mark all comics of the current strip as read.
C        Mark all favorites comics as read.
C-cC-r   Change the default resizing for the current comic.
C-cC-f   Download all of today's favorite comics.
C-cC-u   Download all unread favorite comics.

Exiting comics:
q        Bury the buffer.
k        Kill all comics buffers.
K        Kill all comic related buffers.
"
"Instructions for Comics lists.")

(defvar comics-list-viewing-instructions
"
In the display buffer, the following commands are available (in
addition to the above commands):
  C-cC-v  View the comic in an external viewer
  n       View the comic from the next day
          (with argument N, view the comic from N days forward)
  N       View the comic from the next day, skipping missing comics
  p       View the comic from the previous day
          (with argument N, view the comic from N days previous)
  P       View the comic from the previous day, skipping missing comics
  b       Set the comic to the default bookmark
          With an argument, prompt for a bookmark name
  B       Set the comic to the default global bookmark
          With an argument, prompt for a bookmark name
  u       Copy the url from which the comic was downloaded to the kill ring.
  i       Copy the comic information (name, date, author) to the kill ring.
  U       Copy the comic url and information to the kill ring.
  D       Copy (Duplicate) the comic file to a prompted-for file.
  SPC     Read the next unread comic from the favorites list.
"
"Instructions for the view buffer.")

(defvar comics-list-resizing-instructions
"  F      Fit the comic to the window
  R      Resize the comic to a percentage of its current size
  O      Restore the original size of the comic
"
"More instructions for the view buffer.")

(defun comics-list-comics-setup ()
  "Create a buffer to interactive display comics."
  (let* ((comic-list comics-categorized-list)
         (beg)
         (comic))
    (switch-to-buffer
     (get-buffer-create comics-list-buffer-name))
    (kill-all-local-variables)
    (setq buffer-read-only nil)
    (erase-buffer)
    (goto-char (point-min))
    (setq beg (point))
    (insert comics-list-prelude)
    (comics-facify-region beg (point) 'comics-list-prelude-face)
    (setq beg (point))
    (when comics-print-list-instructions
      (insert comics-list-instructions)
      (unless comics-view-comics-with-external-viewer
        (insert comics-list-viewing-instructions)
        (if (and
             comics-buffer-resize
             (executable-find comics-convert-program))
            (insert comics-list-resizing-instructions)))
      (comics-facify-region beg (point) 'comics-list-instructions-face))
    (insert "\n\n")
    (setq comics-list-beg-point (point))
    (while comic-list
      (insert (caar comic-list))
      (comics-facify-line 'comics-list-category-face)
      (insert "\n")
      (setq comic-list (cdr comic-list)))
    (goto-char comics-list-beg-point)
    (when (fboundp 'view-page-size-default)
      (setq view-page-size (view-page-size-default view-page-size))
      (setq view-half-page-size (or view-half-page-size (/ (view-window-size) 2))))
    (setq buffer-read-only t)))

(defvar comics-list-buffer-keymap nil
  "The keymap for the comics list buffer.")

(if comics-list-buffer-keymap
    nil
  (let ((map (make-sparse-keymap)))
    (define-key map "n" 'next-line)
    (define-key map "p" 'previous-line)
    (define-key map "\t" 'comics-list-toggle-category)
    (define-key map "\C-c\C-e" 'comics-list-expand-all-categories)
    (define-key map "\C-c\C-h" 'comics-list-hide-all-categories)
    (define-key map "q" 'comics-bury-comic-related-buffers)
    (define-key map "\C-c\C-d" 'comics-list-fetch-this-comic-back)
    (define-key map "\C-c\C-f" 'comics-fetch-favorite-comics)
    (define-key map "\C-c\C-u" 'comics-fetch-unread-favorites)
    (define-key map "\C-m" 'comics-list-read-comic)
    (define-key map "r" 'comics-list-read-comic)
    (define-key map "R" 'comics-list-fetch-comic)
    (define-key map "F" 'comics-list-fetch-comic)
    (define-key map "d" 'comics-list-read-comic-date)
    (define-key map "D" 'comics-list-fetch-comic-date)
    (define-key map "g" 'comics-list-goto-bookmark)
    (define-key map "G" 'comics-goto-global-bookmark)
    (define-key map "\C-c\C-b" 'comics-list-delete-bookmark)    
    (define-key map "\C-c\C-g" 'comics-delete-global-bookmark)    
    (define-key map "f" 'comics-list-add-comic-to-favorites)
    (define-key map "\C-c\C-k" 'comics-list-remove-comic-from-favorites)
    (define-key map "l" 'comics-goto-comics-favorites-list)
    (define-key map "L" 'comics-no-op)
    (define-key map "k" 'comics-kill-comics-buffers-query)
    (define-key map "K" 'comics-kill-comic-related-buffers-query)
    (define-key map "c" 'comics-list-catch-up-comic)
    (define-key map "C" 'comics-favorites-catch-up-all)
    (define-key map " " 'comics-list-read-first-unread-comic)
    (define-key map "\C-c\C-r" 'comics-list-change-resizing-info)
    (define-key map "\C-c\C-s" 'comics-list-change-storage-info)
    (setq comics-list-buffer-keymap map)))

(defun comics-list-comics-mode ()
"The comics list consists of categories (not indented) and comics (indented).
Favorite comics are in bold.
The following commands are available:

Displaying the list:
\\[comics-list-toggle-category]
  Toggle the display of the comics in the current category.
\\[comics-list-expand-all-categories]
  Display all the comics in all the categories.
\\[comics-list-hide-all-categories]
  Hide all the comics.

Viewing the comics:
\\[comics-list-read-comic]
  Retrieve and display the comic on the current line.
  (With a numeric argument n, get the comic from n 
   days ago.  With a non-numeric argument, such as C-u RET,
   get the comic from a prompted for date.)
  If the point is on a category line, toggle the display of
  the comics in the category.
\\[comics-list-fetch-comic]
  Like the previous command, but the comic is only downloaded, 
  not displayed.
\\[comics-list-read-comic-date]
  Read the comic on the current line at a prompted for date.
\\[comics-list-fetch-comic-date]
  Like the previous command, but the comic is only downloaded.
\\[comics-list-fetch-this-comic-back]
  Fetch this comic (current and older strips).
\\[comics-list-goto-bookmark]
  Go to the default bookmark.
  With an argument, prompt for a bookmark name
\\[comics-goto-global-bookmark]
  Go to a global bookmark.
  With an argument, prompt for a bookmark name
\\[comics-list-delete-bookmark]
  Delete a bookmark.
\\[comics-list-delete-global-bookmark]
  Delete a global bookmark

Favorites:
\\[comics-list-add-comic-to-favorites]
  Add the current comic to the favorite comics list
\\[comics-list-remove-comic-from-favorites]
  Remove the current comic from the favorite comics list
\\[comics-list-read-first-unread-comic]
  Read the first unread comic.
\\[comics-buffer-catch-up]
  Mark all of the current strip as read.
\\[comics-favorites-catch-up-all]
  Mark all comics as read.
\\[comics-buffer-change-resizing-info]
  Change the default resizing for the current comic.
\\[comics-goto-comics-favorites-list]
  Switch to list of favorite comics.
\\[comics-fetch-favorite-comics]
  Download all of today's favorite comics.
\\[comics-fetch-unread-favorites]
  Download all unread favorite comics.

Exiting:
\\[comics-bury-comic-related-buffers]
  Bury the buffer.
\\[comics-kill-comics-buffers-query]
  Kill all comics buffers.
\\[comics-kill-comic-related-buffers-query]
  Kill all comic related buffers.

In the display buffer, the following commands are available (in
addition to the above commands):
  C-cC-v  View the comic in an external viewer
  n       View the comic from the next day
          (with argument N, view the comic from N days forward)
  N       View the comic from the next day, skipping missing comics
  p       View the comic from the previous day
          (with argument N, view the comic from N days previous)
  P       View the comic from the previous day, skipping missing comics
  b       Set the comic to the default bookmark
          With an argument, prompt for a bookmark name
  B       Set the comic to the default global bookmark
          With an argument, prompt for a bookmark name
  SPC     Read the next unread comic from the favorites list
  F       Fit the comic to the window
  R       Resize the comic to a percentage of its current size
  O       Restore the original size of the comic

\\{comics-list-buffer-keymap}"
  (use-local-map comics-list-buffer-keymap)
  (setq mode-name "Comics list")
  (setq major-mode 'comics-list-comics-mode)
;  (add-hook 'kill-buffer-hook
;            'comics-write-favorites-file)
  (run-hooks 'comics-list-comics-hook))

(defun comics-list-comics ()
  "Create a buffer to interactively display comics."
  (interactive)
  (comics-list-comics-setup)
  (setq comics-list-current-line-overlay
        (make-overlay (line-beginning-position)
                      (line-end-position)))
  (overlay-put comics-list-current-line-overlay
               'face
               'comics-list-current-face)
  (add-hook 'post-command-hook 'comics-list-post-command-hook nil t)
  (comics-list-comics-mode))

(defun comics-goto-comics-list ()
  "Go to the comics list.
Create it if it doesn't exist."
  (interactive)
  (if (get-buffer comics-list-buffer-name)
      (switch-to-buffer comics-list-buffer-name)
    (comics-list-comics)))

;;; The comics favorites buffers

;;; Some functions for comics favorites

(defun comics-favorites-list-read-comic (arg)
  "Read the comic on the current line."
  (interactive "P")
  (let ((comic (comics-favorites-comic-name)))
    (when comic
      (comics-read-comic comic arg))))

(defun comics-favorites-list-read-comic-date ()
  "Read the comic on the current line from the prompted for date."
  (interactive)
  (let ((comic (comics-favorites-comic-name)))
    (when comic
      (let ((date (read-string "Date (YYYYMMDD): ")))
        (comics-read-comic comic date)))))

(defun comics-favorites-list-fetch-comic (arg)
  "Fetch the comic on the current line."
  (interactive "P")
  (let ((comic (comics-favorites-comic-name)))
    (when comic
      (comics-fetch-comic comic arg))))

(defun comics-favorites-list-fetch-this-comic-back (arg)
  "Fetch all possible strips for the comic on the current line."
  (interactive "P")
  (let ((comic (comics-favorites-comic-name)))
    (when comic
      (comics-fetch-this-comic-back comic arg))))

(defun comics-favorites-list-fetch-comic-date ()
  "Fetch the comic on the current line from the prompted for date."
  (interactive)
  (let ((comic (comics-favorites-comic-name)))
    (when comic
      (let ((date (read-string "Date (YYYYMMDD): ")))
        (comics-fetch-comic comic date)))))

(defun comics-favorites-list-goto-default-bookmark ()
  "Read the comic at the default bookmark."
  (let ((comic (comics-favorites-comic-name)))
    (when comic
      (if (comics-bookmark-check-default-bookmark comic)
          (comics-bookmark-goto-bookmark comic "")
        (message (concat "No default bookmark for \"" comic "\""))))))

(defun comics-favorites-list-goto-named-bookmark ()
  "Read the comic at the given bookmark."
  (let ((comic (comics-favorites-comic-name))
        (bookmark))
    (when comic
      (if (assoc comic comics-bookmarks)
          (progn
            (setq bookmark 
                  (comics-completing-read 
                   (concat "Bookmark for \"" comic "\": ") 
                   (cdr (assoc comic comics-bookmarks))))
            (comics-bookmark-goto-bookmark comic bookmark))
        (message (concat "No bookmarks for \"" comic "\""))))))

(defun comics-favorites-list-goto-bookmark (arg)
  "Go to the comic at a bookmark.
With an arg, prompt for a name, otherwise use the default bookmark."
  (interactive "P")
  (if arg
      (comics-favorites-list-goto-named-bookmark)
    (comics-favorites-list-goto-default-bookmark)))

(defun comics-favorites-list-delete-bookmark ()
  "Delete the bookmark."
  (interactive)
  (let ((beg nil)
        (end)
        (comic-name)
        (bookmark)
        (def nil))
    (when (>= (point) comics-list-beg-point)
      (save-excursion
        (beginning-of-line)
        (setq beg (point))
        (end-of-line)
        (setq end (point)))
      (setq def (buffer-substring-no-properties beg end)))
    (setq comic-name
          (comics-completing-read "Comic: " comics-bookmarks def))
    (setq bookmark 
          (comics-completing-read 
           (concat "Bookmark for \""  comic-name "\" to delete: ")
           (cdr (assoc comic-name comics-bookmarks))))
    (comics-bookmark-delete-this-bookmark comic-name bookmark)))

(defun comics-favorites-list-remove-comic-from-favorites ()
  "Remove the comic on the current line from the favorites list."
  (interactive)
  (let ((beg nil)
        (end))
    (save-excursion
      (when (>= (point) comics-list-beg-point)
        (beginning-of-line)
        (unless (looking-at "^ *$")
          (setq beg (point)))
        (end-of-line)
        (setq end (point))))
    (when beg
      (comics-remove-favorite (buffer-substring-no-properties beg end)))))

(defun comics-favorites-list-kill-favorite ()
  "Remove the comic on the current line from the favorites list.
Add it to comics-favorites-kill-list."
  (interactive)
  (let ((beg nil)
        (end))
    (save-excursion
      (when (>= (point) comics-list-beg-point)
        (beginning-of-line)
        (unless (looking-at "^ *$")
          (setq beg (point)))
        (end-of-line)
        (setq end (point))))
    (when beg
      (let ((comic (buffer-substring-no-properties beg end)))
        (setq comics-favorites-kill-list 
              (cons (assoc comic comics-favorites-list) 
                    comics-favorites-kill-list))
        (comics-remove-favorite comic)))))

(defun comics-favorites-list-yank-favorite ()
  "Add the comic from comics-favorites-kill-list to the favorites list."
  (interactive)
  (let* ((beg nil)
        (end)
        (before nil)
        (ncomic (car comics-favorites-kill-list))
        (comic (nth 0 ncomic)))
    (if (not comics-favorites-kill-list)
        (message "No killed comics to yank.")
      (setq comics-favorites-kill-list (cdr comics-favorites-kill-list))
      (save-excursion
        (if (< (point) comics-list-beg-point)
            (goto-char comics-list-beg-point))
        (beginning-of-line)
        (setq beg (point))
        (end-of-line)
        (setq end (point)))
      (setq before (buffer-substring-no-properties beg end))
      (comics-add-favorite-to-list 
       (nth 0 ncomic) (nth 2 ncomic) (nth 3 ncomic) before (nth 1 ncomic))
      (when (get-buffer comics-favorites-list-buffer-name)
        (set-buffer comics-favorites-list-buffer-name)
        (comics-favorites-list-refresh-buffer))
      (when (get-buffer comics-list-buffer-name)
        (save-excursion
          (set-buffer comics-list-buffer-name)
          (save-excursion
            (goto-char (point-min))
            (when (search-forward (concat "  " comic "\n"))
              (forward-line -1)
              (comics-facify-line 'comics-favorites-face))))))))

;;; Setting things up

(defvar comics-favorites-list-current-line-overlay nil)
(make-variable-buffer-local 'comics-favorites-list-current-line-overlay)

(defun comics-favorites-list-post-command-hook ()
  "A function to move the overlay indicating the current line."
  (if (< (point) comics-list-beg-point)
      (move-overlay comics-favorites-list-current-line-overlay
                    (line-beginning-position)
                    (line-beginning-position)
                    (get-buffer comics-favorites-list-buffer-name))
    (move-overlay comics-favorites-list-current-line-overlay
                  (line-beginning-position)
                  (line-end-position)
                  (get-buffer comics-favorites-list-buffer-name))))

;;; The texts

(defvar comics-favorites-list-prelude
"COMIC FAVORITES LIST
====================
"
"A string to put at the beginning of a favorite comics list buffer.")

(defvar  comics-favorites-list-instructions 
"Instructions:
Viewing the comics:
r or RET Retrieve and display the comic on the current line.
         (With a numeric argument n, get the comic from n 
         days ago.  With a non-numeric argument, such as C-u RET,
         get the comic from a prompted for date.)
         If the point is on a category line, toggle the display of
         the comics in the category.
R or F   Like \"r\", but doesn't display the comic, only fetches it.
d        Read the comic on the current line at a prompted for date.
D        Like \"d\", but doesn't display the comic, only fetches it.
C-cC-d   Fetch this comic back (current and older strips).
g        Go to the default bookmark.
         With an argument, prompt for a bookmark name
G        Go to a global bookmark.
         With an argument, prompt for a bookmark name
C-cC-b   Delete a bookmark.
C-cC-g   Delete a global bookmark.

Adjusting the favorite comics:
f        Add a comic to favorite comics list.
l        Go to a list of favorite comics.
L        Go to a list of all comics.
C-cC-k   Remove current comic from favorite comics list.
SPC      Read the first unread comic of the current strip.
c        Mark all comics of the current strip as read.
C        Mark all favorites comics as read.
C-cC-r   Change the default resizing for the current comic.
C-cC-f   Download all of today's favorite comics.
C-cC-u   Download all unread favorite comics.

Exiting comics:
q        Bury the buffer.
k        Kill all comics buffers.
K        Kill all comic related buffers.
"
"Instructions for Comics lists.")

(defvar comics-favorites-list-motion-commands 
"
Adjusting the comics list:
C-cC-a   Put the comics in alphabetical order.
C-k      Kill the current comic.
C-y      Yank the last killed comic back.
"
"Instructions for moving comics around.")

(defun comics-favorites-list-comics-setup ()
  "Create a buffer to interactive display favorite comics."
  (let* ((comic-list comics-favorites-list)
         (beg)
         (comic))
    (switch-to-buffer
     (get-buffer-create comics-favorites-list-buffer-name))
    (kill-all-local-variables)
    (setq buffer-read-only nil)
    (erase-buffer)
    (goto-char (point-min))
    (setq beg (point))
    (insert comics-favorites-list-prelude)
    (comics-facify-region beg (point) 'comics-list-prelude-face)
    (setq beg (point))
    (when comics-print-list-instructions
      (insert comics-favorites-list-instructions)
      (unless comics-favorites-alphabetical
        (insert comics-favorites-list-motion-commands))
      (unless comics-view-comics-with-external-viewer
        (insert comics-list-viewing-instructions)
        (if (and
             comics-buffer-resize
             (executable-find comics-convert-program))
            (insert comics-list-resizing-instructions)))
      (comics-facify-region beg (point) 'comics-list-instructions-face))
    (insert "\n\n")
    (setq comics-list-beg-point (point))
    (while comic-list
      (insert (caar comic-list))
;      (comics-facify-line 'comics-list-category-face)
      (insert "\n")
      (setq comic-list (cdr comic-list)))
    (goto-char comics-list-beg-point)
    (when (fboundp 'view-page-size-default)
      (setq view-page-size (view-page-size-default view-page-size))
      (setq view-half-page-size (or view-half-page-size (/ (view-window-size) 2))))
    (setq buffer-read-only t)))

(defun comics-favorites-list-refresh-buffer ()
  "Refresh the buffer of favorite comics."
  (interactive)
  (let ((pt (point))
        (comic-list comics-favorites-list)
        (beg)
        (comic))
    (setq buffer-read-only nil)
    (goto-char comics-list-beg-point)
    (delete-region (point) (point-max))
    (while comic-list
      (insert (caar comic-list))
      (insert "\n")
      (setq comic-list (cdr comic-list)))
    (setq buffer-read-only t)
    (goto-char (min pt (point-max)))))

(defvar comics-favorites-list-buffer-keymap nil
  "The keymap for the favorites comics list buffer.")

(if comics-favorites-list-buffer-keymap
    nil
  (let ((map (make-sparse-keymap)))
    (define-key map "n" 'next-line)
    (define-key map "p" 'previous-line)
    (define-key map "q" 'comics-bury-comic-related-buffers)
    (define-key map "k" 'comics-kill-comics-buffers-query)
    (define-key map "K" 'comics-kill-comic-related-buffers-query)
    (define-key map "\C-c\C-d" 'comics-favorites-list-fetch-this-comic-back)
    (define-key map "\C-c\C-f" 'comics-fetch-favorite-comics)
    (define-key map "\C-c\C-u" 'comics-fetch-unread-favorites)
    (define-key map "\C-m" 'comics-favorites-list-read-comic)
    (define-key map "r" 'comics-favorites-list-read-comic)
    (define-key map "R" 'comics-favorites-list-fetch-comic)
    (define-key map "F" 'comics-favorites-list-fetch-comic)
    (define-key map "d" 'comics-favorites-list-read-comic-date)
    (define-key map "D" 'comics-favorites-list-fetch-comic-date)
    (define-key map "g" 'comics-favorites-list-goto-bookmark)
    (define-key map "G" 'comics-goto-global-bookmark)
    (define-key map "f" 'comics-add-favorite)
    (define-key map "\C-c\C-a" 'comics-alphabetize-favorites)
    (define-key map "\C-c\C-k" 'comics-favorites-list-remove-comic-from-favorites)
    (define-key map "\C-k" 'comics-favorites-list-kill-favorite)
    (define-key map "\C-y" 'comics-favorites-list-yank-favorite)
    (define-key map "c" 'comics-favorites-catch-up-comic)
    (define-key map "C" 'comics-favorites-catch-up-all)
    (define-key map "\C-c\C-r" 'comics-favorites-change-resizing-info)
    (define-key map "\C-c\C-s" 'comics-favorites-change-storage-info)
    (define-key map "\C-c\C-l" 'comics-favorites-list-refresh-buffer)
    (define-key map "L" 'comics-goto-comics-list)
    (define-key map "l" 'comics-no-op)
    (define-key map " " 'comics-favorites-list-read-first-unread-comic)
    (define-key map "\C-c\C-b" 'comics-favorites-list-delete-bookmark)    
    (define-key map "\C-c\C-g" 'comics-delete-global-bookmark)    
    (setq comics-favorites-list-buffer-keymap map)))

(defun comics-favorites-list-comics-mode ()
"The following commands are available in the favorites comics
list buffer:

Viewing the comics:
\\[comics-favorites-list-read-comic]
  Retrieve and display the comic on the current line.
  (With a numeric argument n, get the comic from n 
   days ago.  With a non-numeric argument, such as C-u RET,
   get the comic from a prompted for date.)
  If the point is on a category line, toggle the display of
  the comics in the category.
\\[comics-favorites-list-fetch-comic]
  Like the previous command, but the comic is only downloaded, 
  not displayed.
\\[comics-favorites-list-read-comic-date]
  Read the comic on the current line at a prompted for date.
\\[comics-favorites-list-fetch-comic-date]
  Like the previous command, but the comic is only downloaded.
\\[comics-favorites-list-fetch-this-comic-back]
  Fetch this comic (current and older strips).
\\[comics-favorites-list-goto-bookmark]
  Go to the default bookmark.
  With an argument, prompt for a bookmark name
\\[comics-goto-global-bookmark]
  Go to a global bookmark.
  With an argument, prompt for a bookmark name
\\[comics-favorites-list-delete-bookmark]
  Delete a bookmark.
\\[comics-delete-global-bookmark]
  Delete a global bookmark

Adjusting the favorites:
\\[comics-add-favorite]
  Add a new comic to the favorites list
\\[comics-favorites-list-remove-comic-from-favorites]
  Remove the current comic from the favorites list
\\[comics-favorites-list-kill-favorite]
  Kill the current comic from the favorites list
\\[comics-favorites-list-yank-favorite]
  Yank a killed comic back to the favorites list
\\[comics-favorites-catch-up-comic]
  Mark the current comic as all read
\\[comics-favorites-catch-up-all]
  Mark all comic as all read
\\[comics-favorites-change-resizing-info]
  Change the automatic resizing information for the current comic
\\[comics-goto-comics-list]
  Go to a buffer with the complete list of comics.
\\[comics-favorites-list-read-first-unread-comic]
  Read the first unread strip from the current comic.
\\[comics-fetch-favorite-comics]
  Download all of today's favorite comics.
\\[comics-fetch-unread-favorites]
  Download all unread favorite comics.

Exiting:
\\[comics-bury-comic-related-buffers]
  Bury the buffer.
\\[comics-kill-comics-buffers-query]
  Kill all comics buffers.
\\[comics-kill-comic-related-buffers-query]
  Kill all comic related buffers.

In the display buffer, the following commands are available (in
addition to the above commands):
  C-cC-v  View the comic in an external viewer
  n       View the comic from the next day
          (with argument N, view the comic from N days forward)
  N       View the comic from the next day, skipping missing comics
  p       View the comic from the previous day
          (with argument N, view the comic from N days previous)
  P       View the comic from the previous day, skipping missing comics
  b       Set the comic to the default bookmark
          With an argument, prompt for a bookmark name
  B       Set the comic to the default global bookmark
          With an argument, prompt for a bookmark name
  SPC     Read the next unread comic from the favorites list
  F       Fit the comic to the window
  R       Resize the comic to a percentage of its current size
  O       Restore the original size of the comic

\\{comics-favorites-list-buffer-keymap}"
  (use-local-map comics-favorites-list-buffer-keymap)
  (setq mode-name "Comic favorites list")
  (setq major-mode 'comics-favorites-list-comics-mode)
;  (add-hook 'kill-buffer-hook
;            'comics-write-favorites-file)
  (run-hooks 'comics-favorites-list-comics-hook))


(defun comics-favorites-list-comics ()
  "Create a buffer to interactively display favorite comics."
  (interactive)
  (comics-favorites-list-comics-setup)
  (setq comics-favorites-list-current-line-overlay
        (make-overlay (line-beginning-position)
                      (line-end-position)))
  (overlay-put comics-favorites-list-current-line-overlay
               'face
               'comics-list-current-face)
  (add-hook 'post-command-hook 'comics-favorites-list-post-command-hook nil t)
  (comics-favorites-list-comics-mode))

(defun comics-goto-comics-favorites-list ()
  "Go to the comics favorites list.
Create it if it doesn't exist."
  (interactive)
  (if (get-buffer comics-favorites-list-buffer-name)
      (switch-to-buffer comics-favorites-list-buffer-name)
    (comics-favorites-list-comics)))

(defun comics-goto-fetch-comics-favorites-list ()
  "Go to the comics favorites list.
If it doesn't exist, create it and fetch the favorite comics."
  (interactive)
  (if (get-buffer comics-favorites-list-buffer-name)
      (switch-to-buffer comics-favorites-list-buffer-name)
    (comics-fetch-unread-favorites)
    (comics-favorites-list-comics)))

(comics-bookmark-read-bookmarks)
(comics-read-favorites-file)
(comics-url-read-urls)

(provide 'comics)

;;; comics.el ends here
