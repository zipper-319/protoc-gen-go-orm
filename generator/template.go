package generator

import (
	"bytes"
	_ "embed"
	"html/template"
	"strings"
)

//go:embed template.go.tpl
var tpl string

type service struct {
	EntityObject string // Greeter
}

func (s *service) execute() string {
	buf := new(bytes.Buffer)
	tmpl, err := template.New("http").Parse(strings.TrimSpace(tpl))
	if err != nil {
		panic(err)
	}
	if err := tmpl.Execute(buf, s); err != nil {
		panic(err)
	}
	return buf.String()
}
