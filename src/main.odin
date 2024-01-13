package todo

import "core:fmt"
import "core:os"
import "core:strings"

HELP :: `
	Usage

	Options:
	list:              List all the non-completed tasks
	add <task>:        Adds a new task to the list.
	done <number>:     Removes a task from the list.
	`

main :: proc() {
	args := os.args

	if len(args) == 1 {
		fmt.println(HELP)
		os.exit(0)
	}

	entry := Argument{args[1], args[2:]}
	err: Error

	switch entry.option {
	case "list":
		err = tasks_list().? or_else nil //Not really sure
	case "add":
		if len(entry.arguments) == 0 {
			err = NoArgs{"add", "<task>"}
			break
		}
		tasks_add(entry.arguments[0]) // just working with first argument, I know :P
		err = tasks_list().? or_else nil //Not really sure
	case "done":
		if len(entry.arguments) == 0 {
			err = NoArgs{"done", "<number>"}
			break
		}
		tasks_done(entry.arguments[0])
		err = tasks_list().? or_else nil //Not really sure
	case:
		message, _ := strings.concatenate({"Option ", entry.option, "is not allowed."})
		err = OptionNotAllowed(message)
	}

	if err != nil {
		switch e in err {
		case FileNotFound:
			fmt.printf("File '%s' doesn't exist. Add a new task.\n", e)
		case OptionNotAllowed:
			fmt.println(e)
			fmt.println(HELP)
		case NoArgs:
			fmt.printf(
				"Incorrect use of option: %s.\nOption %s expected %s as argument.\n",
				e.option,
				e.option,
				e.expected,
			)
		}
	}
}
