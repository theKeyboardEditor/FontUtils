function entry(file_name::String)
	open(file_name) do f
		while !eof(f)
			line = readline(f)
			if startswith(line, "#") continue end

			line = split(line, ";")
			if length(line) != 2
				throw(DomainError(line, "too many parameters in line"))
			end

			for char in split(line[2], " ")
				print(Char.(parse(Int, "0x" * char)))
			end
		end
	end
	nothing
end
entry(ARGS[1])
