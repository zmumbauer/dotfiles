brewfile_path = ENV.fetch("BREWFILE_PATH")
app_id = ENV.fetch("APP_ID")
app_name = ENV.fetch("APP_NAME")

lines = File.readlines(brewfile_path, chomp: true)
mas_header = "# Mac App Store apps. Sign into the App Store before running the installer."
section_start = lines.index(mas_header)
abort("Could not find the MAS section in #{brewfile_path}") unless section_start

section_end = ((section_start + 1)...lines.length).find do |index|
  lines[index].start_with?("# ") && lines[index] != mas_header
end || lines.length

mas_line_pattern = /^mas "((?:\\.|[^"])*)", id: (\d+)$/
mas_lines = lines[(section_start + 1)...section_end].select { |line| line.start_with?('mas "') }

parsed_entries = mas_lines.filter_map do |line|
  match = line.match(mas_line_pattern)
  next unless match

  unescaped_name = match[1].gsub('\"', '"').gsub('\\\\', '\\')
  { name: unescaped_name, id: match[2], line: line }
end

existing = parsed_entries.find { |entry| entry[:id] == app_id || entry[:name] == app_name }
if existing
  puts "EXISTS\t#{existing[:line]}"
  exit 0
end

escaped_name = app_name.gsub('\\', '\\\\').gsub('"', '\"')
new_line = "mas \"#{escaped_name}\", id: #{app_id}"
updated_lines = (mas_lines + [new_line]).sort_by do |line|
  match = line.match(mas_line_pattern)
  sort_name = match ? match[1].gsub('\"', '"').gsub('\\\\', '\\') : line
  sort_name.downcase
end

lines[(section_start + 1)...section_end] = updated_lines
File.write(brewfile_path, "#{lines.join("\n")}\n")

puts "ADDED\t#{new_line}"
