func init(){
    {{range .EntityObject}}
        handlers = append(handlers, func(){
               handlerORM({{.}}{})
        })
    {{end}}
}