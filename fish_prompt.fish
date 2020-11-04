function git::repo_stargazers
	set -l curl_command (string join "" "{\"path\": \"" $argv "\"}")
	curl -s -d $curl_command -H 'Content-Type: application/json' -X POST lysand.re:3010/repo_stars
end


function huggingface::repo_stargazers
	set -l is_git_repo (git rev-parse --is-inside-work-tree ^/dev/null)
	set stargazers_found 0
	
	if test -n "$is_git_repo"
		if git remote | grep -q origin
			set -l origin_url (git remote get-url origin)
			set -l is_origin_github_url (string match -- '*github.com*' $origin_url)
			if test -n "$is_origin_github_url"
				set -l current_date_time (date +%s)
				set -l organization___repository (string join "___" (string split -r / https://github.com/huggingface/transformers | tail -n 2))
				set -l repo_identifier HUGGINGFACE___$organization___repository
				set -l repo_identifier_stars HUGGINGFACE___STARS___$organization___repository

				# There has to be a better way to do this.
				set -l previous_value (string split " " (set | grep -q $repo_identifier) | head -n 2 | tail -n 1)
				set -l previous_value_stars (string split " " (set | grep -q $repo_identifier_stars) | head -n 2 | tail -n 1)

				if test -n "$previous_value" 
					set -l last_date_time (math $previous_value + 10)
					if test $current_date_time -gt $last_date_time
						# Set the stargazers
						set -l stargazers (git::repo_stargazers $origin_url) 
						if string match -qr '^[0-9]+$' $stargazers
							echo $stargazers
							set stargazers_found 1

							# Set the environment variable again
							set -Ux $repo_identifier $current_date_time
							set -Ux $repo_identifier_stars $stargazers
						end
					else
						echo $previous_value_stars 
					end
				else
					# Set the stargazers
					set -l stargazers (git::repo_stargazers $origin_url) 
					if string match -qr '^[0-9]+$' $stargazers
						echo $stargazers
						set stargazers_found 1

						# Set the environment variable again
						set -Ux $repo_identifier $current_date_time
						set -Ux $repo_identifier_stars $stargazers
					end
				end
			end
		end
	end
	
	if test $stargazers_found -eq 0
		echo 🌟
	end
end

function huggingface::set_date_time
	set -Ux HUGGINGFACE_$argv (date +%s)
end

function huggingface::get_date_time
	set -l identifier HUGGINGFACE_$argv
	echo $HUGGINGFACE_$argv
end

function fish_prompt
	set -l textcol  $fish_color_cwd
	set -l huggingface_orange f70
	set_color $textcol -b normal

	if [ -n "$SSH_CONNECTION" ]
		printf '%s | ' (hostname | head -c 10)
	end
	if [ "$HOME" = (pwd) ]
		printf "~"
	else
		printf (dirs)
	end

	printf (string join "" " (" (huggingface::repo_stargazers) ")")

	set_color $huggingface_orange
	printf " 🤗 "
	set_color $textcol -b normal
end
