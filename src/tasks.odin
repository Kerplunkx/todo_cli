package todo

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

//TODO: Search for the 'todos.txt' file inside this dir and not cwd.
//NOTE: Not sure why am I getting execution permission on the file

@(private = "file")
file_read_lines :: proc(path: string) -> ([dynamic]string, bool) {
	lines: [dynamic]string
	data, ok := os.read_entire_file(path)
	if !ok {
		return nil, false
	}

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		append(&lines, line)
	}
	return lines, true
}

//TODO: Add custom files support.
tasks_list :: proc() -> Maybe(Error) {
	lines, ok := file_read_lines("todos.txt")
	defer delete(lines)

	if !ok {
		return FileNotFound("todos.txt")
	}
	for line, i in 0 ..< len(lines) {
		fmt.printf("%d: %s\n", i + 1, lines[line])
	}
	return nil
}

tasks_add :: proc(task: string) {
	f_handle, f_err := os.open(
		"todos.txt",
		os.O_CREATE | os.O_WRONLY | os.O_APPEND,
		os.S_IRUSR | os.S_IWUSR,
	)
	defer os.close(f_handle)
	if f_err != os.ERROR_NONE {
		fmt.eprintln("Error adding task.")
		os.exit(-1)
	}
	new_task, concat_err := strings.concatenate({task, "\n"})
	if concat_err != nil {
		fmt.eprintln("Error adding task.")
		os.exit(-1)
	}
	os.write_string(f_handle, new_task)
}

tasks_done :: proc(task: string) {
	tf_handle, _ := os.open(
		"temp.txt",
		os.O_CREATE | os.O_WRONLY | os.O_APPEND,
		os.S_IRUSR | os.S_IWUSR,
	)
	tasks, ok := file_read_lines("todos.txt")
	if !ok {
		fmt.eprintln("Error removing task.")
	}
	id := strconv.atoi(task) - 1
	ordered_remove(&tasks, id)
	for line in tasks {
		new_line, _ := strings.concatenate({line, "\n"})
		os.write_string(tf_handle, new_line)
	}
	os.remove("todos.txt")
	os.rename("temp.txt", "todos.txt")
}
