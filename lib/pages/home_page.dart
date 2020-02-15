import 'package:flutter/material.dart';
import '../service/service_method.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/ball_pulse_footer.dart';
import '../routers/application.dart';

class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  int page = 1;
  List<Map> hotGoodsList = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    print('1111111');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('买买酒'),
        ),
        body: FutureBuilder(
          future: getHomePageContent(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = json.decode(snapshot.data.toString());
              List<Map> swiper =
                  (data['data']['slides'] as List).cast(); // 顶部轮播组件数
              List<Map> navgatorList =
                  (data['data']['category'] as List).cast(); // 顶部轮播组件数
              String adPicture =
                  data['data']['advertesPicture']['PICTURE_ADDRESS'];
              String leaderImage = data['data']['shopInfo']['leaderImage'];
              String leaderPhone = data['data']['shopInfo']['leaderPhone'];
              List<Map> recommendList =
                  (data['data']['recommend'] as List).cast();
              String floor1Title = data['data']['floor1Pic']['PICTURE_ADDRESS'];
              String floor2Title = data['data']['floor2Pic']['PICTURE_ADDRESS'];
              String floor3Title = data['data']['floor3Pic']['PICTURE_ADDRESS'];
              List<Map> floor1 = (data['data']['floor1'] as List).cast();
              List<Map> floor2 = (data['data']['floor2'] as List).cast();
              List<Map> floor3 = (data['data']['floor3'] as List).cast();

              return EasyRefresh(
                  footer: BallPulseFooter(),
                  child: ListView(
                    children: <Widget>[
                      SwiperDiy(swiperDataList: swiper), //页面顶部轮播组件
                      TopNavigator(navgatorList: navgatorList),
                      AdBanner(adPicture: adPicture),
                      LeaderPhone(
                          leaderImage: leaderImage, leaderPhone: leaderPhone),
                      Recommend(
                        recommendList: recommendList,
                      ),
                      FloorTitle(picture_address: floor1Title),
                      FloorContent(
                        floorGoodsList: floor1,
                      ),
                      FloorTitle(picture_address: floor2Title),
                      FloorContent(
                        floorGoodsList: floor2,
                      ),
                      FloorTitle(picture_address: floor3Title),
                      FloorContent(
                        floorGoodsList: floor3,
                      ),
                      _hotGoods()
                    ],
                  ),
                  onLoad: () async {
                    print('开始加载更多.....');
                    var formData = {'page': page};
                    await request('homePageBelowConten', formData: formData)
                        .then((val) {
                      var data = json.decode(val.toString());
                      List<Map> newGoodsList = (data['data'] as List).cast();
                      setState(() {
                        hotGoodsList.addAll(newGoodsList);
                        page++;
                      });
                    });
                  });
            } else {
              return Center(
                child: Text('加载中...'),
              );
            }
          },
        ));
  }

  Widget hotTitle = Container(
      margin: EdgeInsets.only(top: 10),
      alignment: Alignment.center,
      color: Colors.transparent,
      padding: EdgeInsets.all(5),
      child: Text('火爆专区'));

  Widget _wrapList() {
    if (hotGoodsList.length != 0) {
      List<Widget> listWidget = hotGoodsList.map((val) {
        return InkWell(
          onTap: () {
            Application.router
                .navigateTo(context, "/details?id=${val['goodsId']}");
          },
          child: Container(
              width: ScreenUtil().setWidth(372),
              color: Colors.white,
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.only(bottom: 3),
              child: Column(
                children: <Widget>[
                  Image.network(val['image'],
                      width: ScreenUtil().setWidth(370)),
                  Text(val['name'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.pink,
                          fontSize: ScreenUtil().setSp(26))),
                  Row(
                    children: <Widget>[
                      Text('￥${val['mallPrice']}'),
                      Text('￥${val['price']}',
                          style: TextStyle(
                              color: Colors.black26,
                              decoration: TextDecoration.lineThrough))
                    ],
                  )
                ],
              )),
        );
      }).toList();

      return Wrap(spacing: 2, children: listWidget);
    } else {
      return Text('');
    }
  }

  Widget _hotGoods() {
    return Container(
      child: Column(
        children: <Widget>[hotTitle, _wrapList()],
      ),
    );
  }
}

// 首页轮播组件编写
class SwiperDiy extends StatelessWidget {
  final List swiperDataList;
  SwiperDiy({Key key, this.swiperDataList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // print('设备宽度:${ScreenUtil.screenWidth}');
    // print('设备高度:${ScreenUtil.screenHeight}');
    // print('设备像素密度:${ScreenUtil.pixelRatio}');
    return Container(
      height: ScreenUtil().setHeight(333),
      width: ScreenUtil().setWidth(750),
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
              onTap: () {
                Application.router.navigateTo(
                    context, "/details?id=${swiperDataList[index]['goodsId']}");
              },
              child: Image.network("${swiperDataList[index]['image']}",
                  fit: BoxFit.fill));
        },
        itemCount: swiperDataList.length,
        pagination: new SwiperPagination(),
        autoplay: true,
      ),
    );
  }
}

class TopNavigator extends StatelessWidget {
  final List navgatorList;

  TopNavigator({Key key, this.navgatorList}) : super(key: key);

  Widget _gridViewItemUI(BuildContext context, item) {
    return InkWell(
        onTap: () {
          print('跳转到XX页面');
        },
        child: Column(children: <Widget>[
          Image.network(item['image'], width: ScreenUtil().setWidth(95)),
          Text(item['mallCategoryName'])
        ]));
  }

  @override
  Widget build(BuildContext context) {
    if (this.navgatorList.length > 10) {
      this.navgatorList.removeRange(10, navgatorList.length);
    }
    return Container(
      height: ScreenUtil().setHeight(320),
      padding: EdgeInsets.all(3),
      child: GridView.count(
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 5,
          padding: EdgeInsets.all(5),
          children: navgatorList.map((item) {
            return _gridViewItemUI(context, item);
          }).toList()),
    );
  }
}

class AdBanner extends StatelessWidget {
  final String adPicture;

  AdBanner({Key key, this.adPicture}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.network(adPicture),
    );
  }
}

// 店长电话
class LeaderPhone extends StatelessWidget {
  // 店长图片
  final String leaderImage;
  // 店长电话
  final String leaderPhone;

  LeaderPhone({Key key, this.leaderImage, this.leaderPhone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: InkWell(
      onTap: _launchURL,
      child: Image.network(leaderImage),
    ));
  }

  void _launchURL() async {
    String url = 'tel:' + leaderPhone;
    print(url);
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

// 商品推荐
class Recommend extends StatelessWidget {
  final List recommendList;

  Recommend({Key key, this.recommendList}) : super(key: key);

  Widget _titleWidget() {
    return Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.fromLTRB(10, 2, 0, 5),
        decoration: BoxDecoration(
            color: Colors.white,
            border:
                Border(bottom: BorderSide(width: 0.5, color: Colors.black12))),
        child: Text('商品推荐', style: TextStyle(color: Colors.pink)));
  }

  //商品单独项目
  Widget _item(context,index) {
    return InkWell(
      onTap: () {
         Application.router.navigateTo(context, "/details?id=${recommendList[index]['goodsId']}");
      },
      child: Container(
          height: ScreenUtil().setHeight(330),
          width: ScreenUtil().setWidth(250),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.white,
              border:
                  Border(left: BorderSide(width: 0.5, color: Colors.black12))),
          child: Column(
            children: <Widget>[
              Image.network(recommendList[index]['image']),
              Text('￥${recommendList[index]['mallPrice']}'),
              Text('￥${recommendList[index]['price']}',
                  style: TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey)),
            ],
          )),
    );
  }

  // 横向列表方法
  Widget _recommendList() {
    return Container(
        height: ScreenUtil().setHeight(330),
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recommendList.length,
            itemBuilder: (context, index) {
              return _item(context,index);
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(380),
      margin: EdgeInsets.only(top: 10),
      child: Column(
        children: <Widget>[_titleWidget(), _recommendList()],
      ),
    );
  }
}

// 楼层标题

class FloorTitle extends StatelessWidget {
  final String picture_address;

  FloorTitle({Key key, this.picture_address}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Image.network(picture_address),
    );
  }
}

// 楼层商品列表
class FloorContent extends StatelessWidget {
  final List floorGoodsList;

  FloorContent({Key key, this.floorGoodsList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[_firstRow(context), _otherGoods(context)],
      ),
    );
  }

  Widget _firstRow(context) {
    return Row(
      children: <Widget>[
        _goodsItem(context,floorGoodsList[0]),
        Column(
          children: <Widget>[
            _goodsItem(context,floorGoodsList[1]),
            _goodsItem(context,floorGoodsList[2]),
          ],
        )
      ],
    );
  }

  Widget _otherGoods(context) {
    return Row(
      children: <Widget>[
        _goodsItem(context,floorGoodsList[3]),
        _goodsItem(context,floorGoodsList[4]),
      ],
    );
  }

  Widget _goodsItem(BuildContext context, Map goods) {
    return Container(
        width: ScreenUtil().setWidth(375),
        child: InkWell(
            onTap: () {
               Application.router.navigateTo(
                    context, "/details?id=${goods['goodsId']}");
            },
            child: Image.network(goods['image'])));
  }
}
