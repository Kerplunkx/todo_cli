package todo

Argument :: struct {
	option:    string,
	arguments: []string,
}

OptionNotAllowed :: string
FileNotFound :: distinct string

NoArgs :: struct {
	option:   string,
	expected: string,
}

Error :: union {
	NoArgs,
	FileNotFound,
	OptionNotAllowed,
}
