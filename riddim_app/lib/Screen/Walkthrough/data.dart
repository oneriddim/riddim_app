class Items {
  String pageNo, description, btnDescription;
  String image;
  //IconData icon;

  Items({this.pageNo, this.description, this.image, this.btnDescription});
}

class ItemsListBuilder {
  List<Items> itemList = new List();

  Items item1 = new Items(
      pageNo: "Accept a JOB",
      description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry",
      image: "assets/image/job.png",
      btnDescription: "Skip To App");
  Items item2 = new Items(
      pageNo: "Tracking Realtime",
      description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industryY",
      image: "assets/image/tracking.png",
      btnDescription: "Skip To App");
  Items item3 = new Items(
      pageNo: "Earn Money",
      description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry",
      image: "assets/image/earn_money.png",
      btnDescription: "Continue To App");

  ItemsListBuilder() {
    itemList.add(item1);
    itemList.add(item2);
    itemList.add(item3);
  }
}
