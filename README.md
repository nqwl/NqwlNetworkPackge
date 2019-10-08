# TableView的性能优化
  代码下载后，cd 到profile所在的目录，pod install一下即可查看。
- 1、网络框架的封装
    - 可控的定时网络数据本地缓存，避免重复的网络请求+统一异常处理机制
- 2、关于Cell高度计算的细节优化(并没有用到self-sizing cell的方式计算高度)
    - 内存缓存Cell高度+根据Cell高度标识减少高度计算次数
- 3、UItableView刷新优化
    - 按需刷新(注意数据与Cell数量的统一,代码有细节处理)
- 4、关于后台数据与需展示的数据存在需要转换的情况处理(时间转换，数据解密等处理)
    - 在自定义model中，重写待转换字段的setter方法，在此方法中进行数据转换。这样的处理，可以将数据转换的操作从页面展示前，提前到数据创建时，一定程度上避免页面刷新卡顿的情况。
- 5、文字高度计算的一些处理
    - 文字高度计算记得考虑行间距
