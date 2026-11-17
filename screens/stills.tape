Source common.tape
Output scratch.gif
Hide
Type "tmux -L revamped-screens attach -t demo"
Enter
Sleep 2s
Type "clear; cat build.log"
Enter
Sleep 1s
Show
Sleep 500ms
Hide
Ctrl+]
Type@5ms "tmux set -g @extract_revamped_navigate_key n; extract-revamped apply"
Enter
Show
Type "tmux set -g @extract_revamped_navigate_key n; extract-revamped apply"
Sleep 400ms
Hide
Ctrl+]
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1500ms
Hide
Type "clear; cat build.log"
Enter
Sleep 500ms
Show
Hide
Ctrl+]
Type@5ms "prefix n, 7d3f, Enter"
Enter
Show
Ctrl+B
Type@1ms "n"
Sleep 2s
Type "7d3f"
Sleep 800ms
Enter
Sleep 1500ms
Screenshot navigate.png
Sleep 1s
Hide
Ctrl+]
Type@5ms "q"
Enter
Show
Type "q"
Sleep 800ms
Hide
Ctrl+]
Type@5ms "tmux set -g @extract_revamped_open_key o; extract-revamped apply"
Enter
Show
Type "tmux set -g @extract_revamped_open_key o; extract-revamped apply"
Sleep 400ms
Hide
Ctrl+]
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1500ms
Hide
Type "clear; cat build.log"
Enter
Sleep 500ms
Show
Hide
Ctrl+]
Type@5ms "prefix o, release.md, Enter"
Enter
Show
Ctrl+B
Type@1ms "o"
Sleep 2s
Type "release.md"
Sleep 800ms
Enter
Sleep 1500ms
Sleep 1s
Screenshot open.png
Sleep 1s
Hide
Ctrl+]
Type@5ms "q"
Enter
Show
Type "q"
Sleep 1s
Hide
Ctrl+]
Type@5ms "tmux set -g @extract_revamped_copy_key y; extract-revamped apply"
Enter
Show
Type "tmux set -g @extract_revamped_copy_key y; extract-revamped apply"
Sleep 400ms
Hide
Ctrl+]
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1500ms
Hide
Type "clear; cat build.log"
Enter
Sleep 500ms
Show
Hide
Ctrl+]
Type@5ms "prefix y, v2.4, Enter"
Enter
Show
Ctrl+B
Type@1ms "y"
Sleep 2s
Type "v2.4"
Sleep 800ms
Enter
Sleep 1500ms
Hide
Ctrl+]
Type@5ms "pbpaste; echo"
Enter
Show
Type "pbpaste; echo"
Sleep 400ms
Hide
Ctrl+]
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1500ms
Screenshot copy.png
Sleep 1s
Hide
Ctrl+]
Type@5ms "tmux set -g @extract_revamped_chooser_key c; tmux set -g @extract_revamped_popup_width 60%; extract-revamped apply"
Enter
Show
Type "tmux set -g @extract_revamped_chooser_key c; tmux set -g @extract_revamped_popup_width 60%; extract-revamped apply"
Sleep 400ms
Hide
Ctrl+]
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1500ms
Hide
Type "clear; cat build.log"
Enter
Sleep 500ms
Show
Hide
Ctrl+]
Type@5ms "prefix c, C-n, Escape"
Enter
Show
Ctrl+B
Type@1ms "c"
Sleep 2s
Ctrl+N
Sleep 1500ms
Screenshot chooser.png
Sleep 1s
Escape
Sleep 2s
Hide
Ctrl+]
Type@5ms "tmux set -g @extract_revamped_mode words; tmux set -g @extract_revamped_min_length 10; tmux set -g @extract_revamped_reverse 1; tmux set -g @extract_revamped_multi 1"
Enter
Show
Type "tmux set -g @extract_revamped_mode words; tmux set -g @extract_revamped_min_length 10; tmux set -g @extract_revamped_reverse 1; tmux set -g @extract_revamped_multi 1"
Sleep 400ms
Hide
Ctrl+]
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1500ms
Hide
Type "clear; cat build.log"
Enter
Sleep 500ms
Show
Hide
Ctrl+]
Type@5ms "prefix M-x, Tab, Tab, Escape"
Enter
Show
Ctrl+B
Escape
Type@1ms "x"
Sleep 2s
Tab
Sleep 500ms
Tab
Sleep 500ms
Screenshot filters.png
Sleep 800ms
Escape
Sleep 2s
Hide
Ctrl+]
Type@5ms "tmux set -g @extract_revamped_min_length 0; tmux set -g @extract_revamped_reverse 0; tmux set -g @extract_revamped_multi 0; tmux set -g @extract_revamped_scope all-panes; tmux split-window -h -d 'echo token-from-the-other-pane; sleep 600'"
Enter
Show
Type "tmux set -g @extract_revamped_min_length 0; tmux set -g @extract_revamped_reverse 0; tmux set -g @extract_revamped_multi 0; tmux set -g @extract_revamped_scope all-panes; tmux split-window -h -d 'echo token-from-the-other-pane; sleep 600'"
Sleep 400ms
Hide
Ctrl+]
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1500ms
Hide
Ctrl+]
Type@5ms "prefix M-x, other, Escape"
Enter
Show
Ctrl+B
Escape
Type@1ms "x"
Sleep 2s
Type "other"
Sleep 800ms
Screenshot all-panes.png
Sleep 800ms
Escape
Sleep 2s
Hide
Type "tmux kill-pane -a -t {left}; tmux set -g @extract_revamped_scope pane; tmux set -g @extract_revamped_mode all; tmux set -g @extract_revamped_doctor_key D; tmux set -g @extract_revamped_popup_width 90%; tmux set -g @extract_revamped_popup_height 90%; extract-revamped apply; clear"
Enter
Sleep 1s
Show
Hide
Ctrl+]
Type@5ms "tmux set -g @extract_revamped_mode git-status; tmux set -g @extract_revamped_edit_key E; tmux set -g @extract_revamped_run_key R; extract-revamped apply"
Enter
Show
Type "tmux set -g @extract_revamped_mode git-status; tmux set -g @extract_revamped_edit_key E; tmux set -g @extract_revamped_run_key R; extract-revamped apply"
Sleep 400ms
Hide
Ctrl+]
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1500ms
Hide
Type "clear; cat status.txt"
Enter
Sleep 800ms
Show
Hide
Ctrl+]
Type@5ms "prefix M-x, Escape"
Enter
Show
Ctrl+B
Escape
Type@1ms "x"
Sleep 2s
Screenshot modes.png
Sleep 800ms
Escape
Sleep 2s
Hide
Ctrl+]
Type@5ms "prefix E, README, Enter, q"
Enter
Show
Ctrl+B
Type@1ms "E"
Sleep 2s
Type "README"
Sleep 800ms
Enter
Sleep 1500ms
Screenshot edit.png
Sleep 800ms
Type "q"
Sleep 1500ms
Hide
Ctrl+]
Type@5ms "prefix R, handler, Enter"
Enter
Show
Ctrl+B
Type@1ms "R"
Sleep 2s
Type "handler"
Sleep 800ms
Enter
Sleep 1500ms
Screenshot run.png
Sleep 4s
Hide
Ctrl+]
Type@5ms "tmux set -g @extract_revamped_picker hints; tmux set -g @extract_revamped_mode urls; extract-revamped apply"
Enter
Show
Type "tmux set -g @extract_revamped_picker hints; tmux set -g @extract_revamped_mode urls; extract-revamped apply"
Sleep 400ms
Hide
Ctrl+]
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1500ms
Hide
Type "clear; cat build.log"
Enter
Sleep 800ms
Show
Hide
Ctrl+]
Type@5ms "prefix M-x, s"
Enter
Show
Ctrl+B
Escape
Type@1ms "x"
Sleep 2s
Screenshot hints.png
Sleep 800ms
Type "s"
Sleep 1500ms
Screenshot hints-typed.png
Sleep 800ms
Hide
Ctrl+U
Type "tmux set -g @extract_revamped_picker fzf; tmux set -g @extract_revamped_mode all; extract-revamped apply; clear"
Enter
Sleep 1s
Show
Hide
Ctrl+]
Type@5ms "prefix D, Enter"
Enter
Show
Ctrl+B
Type@1ms "D"
Sleep 4s
Screenshot doctor-popup.png
Sleep 1s
Enter
Sleep 1s
Hide
Type "clear"
Enter
Show
Hide
Ctrl+]
Type@5ms "extract-revamped list"
Enter
Show
Type "extract-revamped list"
Sleep 400ms
Hide
Ctrl+]
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1500ms
Screenshot list.png
Sleep 1s
Hide
Type "clear"
Enter
Show
Hide
Ctrl+]
Type@5ms "extract-revamped list --json"
Enter
Show
Type "extract-revamped list --json"
Sleep 400ms
Hide
Ctrl+]
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1500ms
Screenshot json.png
Sleep 1s
Hide
Type "clear"
Enter
Show
Hide
Ctrl+]
Type@5ms "extract-revamped version"
Enter
Show
Type "extract-revamped version"
Sleep 400ms
Hide
Ctrl+]
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1500ms
Screenshot version.png
Sleep 1s
Hide
Type "clear"
Enter
Show
Hide
Ctrl+]
Type@5ms "extract-revamped frobnicate"
Enter
Show
Type "extract-revamped frobnicate"
Sleep 400ms
Hide
Ctrl+]
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1500ms
Screenshot error.png
Sleep 1s
Hide
Type "clear"
Enter
Show
Hide
Ctrl+]
Type@5ms "EXTRACT_REVAMPED_ACCENT=#89DCEB extract-revamped"
Enter
Show
Type "EXTRACT_REVAMPED_ACCENT='#89DCEB' extract-revamped"
Sleep 400ms
Hide
Ctrl+]
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3s
Screenshot accent.png
Sleep 1s
Hide
Ctrl+]
Type@5ms "Escape"
Enter
Show
Escape
Sleep 2s
Hide
Type "clear"
Enter
Show
Hide
Ctrl+]
Type@5ms "extract-revamped"
Enter
Show
Type "extract-revamped"
Sleep 400ms
Hide
Ctrl+]
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3s
Screenshot menu.png
Sleep 1s
Hide
Ctrl+]
Type@5ms "Down Down Enter"
Enter
Show
Down
Sleep 400ms
Down
Sleep 400ms
Enter
Sleep 5s
Screenshot doctor.png
Sleep 1s
Hide
Type "clear"
Enter
Show
Hide
Type "export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/Users/Shared/demo/bin:/Users/Shared/demo/tmux-extract-revamped/bin"
Enter
Type "clear"
Enter
Show
Hide
Ctrl+]
Type@5ms "extract-revamped"
Enter
Show
Type "extract-revamped"
Sleep 400ms
Hide
Ctrl+]
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1500ms
Screenshot plain-menu.png
Sleep 1s
Hide
Ctrl+]
Type@5ms "2 Enter"
Enter
Show
Type "2"
Sleep 400ms
Enter
Sleep 3s
Screenshot plain-apply.png
Sleep 1s
