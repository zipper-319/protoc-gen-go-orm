var bc conf.Bootstrap

func init() {
	c := config.New(
		config.WithSource(
			file.NewSource("../../../../configs"),
		),
	)
	defer c.Close()

	if err := c.Load(); err != nil {
		panic(err)
	}

	if err := c.Scan(&bc); err != nil {
		panic(err)
	}
}

func main() {
	var ormObj = {{$.EntityObject}}{}
	db := model.NewDataDB(bc.Data)
	if !db.Migrator().HasTable(&ormObj) {
		if err := db.Migrator().CreateTable(ormObj); err != nil {
			log.Println(err)
		}
	} else {
		log.Println("table already exists")
	}
	showTable := make(map[string]interface{})
	db.Raw(fmt.Sprintf("show create table %s", ormObj.TableName())).Scan(&showTable)
	content := showTable["Create Table"].(string)
	objSqlFile := fmt.Sprintf("../sql/%s.sql", ormObj.TableName())
	if _, err := os.Stat(objSqlFile); os.IsNotExist(err) {
		if f, err := os.Create(objSqlFile); err == nil {
			f.Write([]byte(content))
		}
	} else {
		startLine := fmt.Sprintf("CREATE TABLE `%s` (", ormObj.TableName())
		endLine := fmt.Sprintf(") ENGINE=InnoDB")
		startLineNum := -1
		endLineNum := 0
		if contentByte, err := os.ReadFile(objSqlFile); err == nil {
			tempList := strings.Split(string(contentByte), "\n")
			for i, l := range tempList {
				if strings.Contains(l, startLine) {
					startLineNum = i
				}
				if startLineNum >= 0 && strings.Contains(l, endLine) {
					endLineNum = i
					break
				}
			}
			fmt.Printf("startLineNum:%d, endLineNum:%d", startLineNum, endLineNum)
            result := make([]string, 0, len(tempList))
            result = append(result, tempList[:startLineNum]...)

            result = append(result, content)
            result = append(result, tempList[endLineNum+1:]...)
            wc := strings.Join(result, "\n")
            f, err := os.Create(objSqlFile)
            defer f.Close()
            if err != nil {
                fmt.Println(err)
                return
            }
            f.WriteString(wc)
		}
	}
}