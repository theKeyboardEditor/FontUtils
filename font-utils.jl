using Downloads
using ZipArchives: ZipBufferReader, zip_readentry

fonts = Dict(
	"https://github.com/dakotafelder/open-cherry/raw/master/OpenCherry-Regular.otf" => nothing,
	"https://github.com/googlefonts/roboto/releases/download/v2.138/roboto-unhinted.zip" => ["Roboto-Regular.ttf"]
)

# Generates the list of characters to be passed into msdf gen
function generate_char_list(file_name::String)
	buffer = IOBuffer()
	open(file_name) do f
		while !eof(f)
			line = readline(f)
			if startswith(line, "#") continue end

			line = split(line, ";")
			if length(line) != 2
				throw(DomainError(line, "too many parameters in line"))
			end

			for char in split(line[2], " ")
				print(buffer, Char.(parse(Int, "0x" * char)) * " ")
			end
		end
	end
	return String(take!(buffer))
end

# Downloads all fonts
function grab_fonts(fonts::Dict{String, Union{Nothing, Vector{String}}})
	Base.Filesystem.mkpath("fonts-out")
	for url in keys(fonts)
		file_name::String = split(url, "/") |> last
		println(file_name)
		if endswith(url, ".otf") || endswith(url, ".ttf")
			Downloads.download(url, "fonts-out/$file_name")
		elseif endswith(url, ".zip")
			data = take!(Downloads.download(url, IOBuffer()));
			archive = ZipBufferReader(data)
			for file in fonts[url]
				font_file = zip_readentry(archive, file, String)
				write("fonts-out/$file", font_file)
			end
		else
			throw(DomainError(file_name, "Filetype not supported"))
		end
	end
	nothing
end

# Generates MSDF atlas gen command: current broken
function generate_msdf_atlas(charset::String, to::String)
	cmd::String = "msdf-atlas-gen"
	i::Integer = 1
	for dir in readdir("fonts-out")
		if i > 1
			cmd *= " -and"
		end
		cmd *= " -font $dir -charset $charset -size 168 -pxrange 4"
		i += 1
	end
	cmd *= "-imageout $to"
	return cmd
end

function entry()
	grab_fonts(fonts)
	write("glyphs.txt", generate_char_list(ARGS[1]))
	generate_msdf_atlas("glyphs.txt", ARGS[2]) |> print
end

entry()
