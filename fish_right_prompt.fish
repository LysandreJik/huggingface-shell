set huggingface_orange f60 --bold

function huggingface::current_branch
	set_color $huggingface_orange
	set -l current_branch (git symbolic-ref --short HEAD --quiet)
	echo (string join "" "(" $current_branch ") ")
end

function huggingface::line_diff
	set -l current_diff_shortstat (git diff --shortstat)
	set -l additions (echo "$current_diff_shortstat" | sed -nE 's/.* ([0-9]+) insertion.*/+\1/p')
	set -l deletions (echo "$current_diff_shortstat" | sed -nE 's/.* ([0-9]+) deletion.*/-\1/p')

	if test -n "$additions"; or test -n "$deletions"
		set_color normal
		echo "("
		set_color 3B3
		echo "$additions"
		if test -n "$additions"; and test -n "$deletions"
			set_color normal
			echo ", "
		end
		set_color B33
		echo "$deletions"
		set_color normal
		echo ") "
	end
end


function fish_right_prompt
	set -l is_git_repo (git rev-parse --is-inside-work-tree 2>/dev/null)

	if test -n "$is_git_repo"
		huggingface::current_branch
		huggingface::line_diff	
		set_color normal
	end

	set_color normal
	set_color $fish_color_cwd
	echo (string join  " " (date "+%H:%M:%S") "~")
end
