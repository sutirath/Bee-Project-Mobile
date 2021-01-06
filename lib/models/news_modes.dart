class NewsModels{

  // Field
  String title, detail,img;

  // Method

    NewsModels(this.title,this.detail,this.img);

    NewsModels.fromMap(Map<String ,dynamic>map){
      title = map['title'];
      detail = map['detail'];
      img = map['img'];
    }

}
