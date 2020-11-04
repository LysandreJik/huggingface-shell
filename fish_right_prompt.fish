function fish_right_prompt
	set -l is_git_repo (git rev-parse --is-inside-work-tree ^/dev/null)
	set -l huggingface_orange f60 --bold

	if test -n "$is_git_repo"
		set_color $huggingface_orange
		echo (string join "" "(" (git symbolic-ref --short HEAD) ") ")
	end

	set_color normal
	set_color $fish_color_cwd
	echo (string join  " " (date "+%H:%M:%S") "~")
end
