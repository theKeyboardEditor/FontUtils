using Downloads
using ZipArchives: ZipBufferReader, zip_readentry

fonts = Dict(
	"https://github.com/dakotafelder/open-cherry/raw/master/OpenCherry-Regular.otf" => nothing,
	"https://github.com/googlefonts/roboto/releases/download/v2.138/roboto-unhinted.zip" => ["Roboto-Regular.ttf"]
)

function entry(fonts::Dict{String, Union{Nothing, Vector{String}}})
	Base.Filesystem.mkpath("fonts-out")
	for url in keys(fonts)
		file_name::String = split(url, "/") |> last
		println(file_name)
		if endswith(url, ".otf") || endswith(url, ".ttf")
			Downloads.download(url, "fonts-out/$file_name")
		else if endswith(url, ".zip")
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
