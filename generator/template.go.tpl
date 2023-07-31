func Create{{ .TableName }}(ctx context.Context) error {
	ormObj := {{ .NameGo }}{}
	//db.AutoMigrate(ormObj)
	var err error
	if !db.Migrator().HasTable(&ormObj){
		err = db.Migrator().CreateTable(ormObj)
	}else{
		log.Println("table already exists")
	}
	return err
}

func Insert{{ .TableName }}(ctx context.Context) error {

}