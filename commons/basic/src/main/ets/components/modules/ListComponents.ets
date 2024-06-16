
@Builder function renderItemInit(item: object): void {}
@Component
struct ListComponents {
  @State
  refreshIng: boolean = false // 控制下拉刷新的变量
  // 传入数据的数组 根据数组进行渲染
  @Prop
  dataSource: object[] = [] // 数据源`
  // 需要一个标记 还没有数据的标记
  @Prop
  finished: boolean = false // 是否还有下一页数据
  @State
  loading: boolean = false // 是否正在加载中 1.显示加载中文本 2. 用来做阀门 当前这次请求没结束之前 下次请求滚远点
  loadingText: string = "加载中.." // 加载中的文本
  finishText: string = "没有数据啦" // 所有数据加载完成的文本
  @BuilderParam
  renderItem: (item: object) => void =renderItemInit// 由调用者传入 由ListCompoents调用 传入每一个项的数据
  @State
  refreshStatus: RefreshStatus = RefreshStatus.Inactive // 记录下拉刷新的状态
  // 上拉加载的方法
  onLoad: () => void = () => {
  } // 由调用者传入
  // 下拉刷新方法
  onRefresh: () => void = () => {
  } // 下拉刷新的方法


  @Builder
  getBottomDisplay() {
    // 获取底部的展示内容
    Row({ space: 10 }) {
      if (this.finished) {
        // 此时应该没有动画的loading
        Text(this.finishText)
          .fontSize(14)
          .fontColor($r("app.color.text_secondary"))
      } else {
        Text(this.loadingText)
          .fontSize(14)
          .fontColor($r("app.color.text_secondary"))
        LoadingProgress()
          .width(20)
          .aspectRatio(1)
          .color($r("app.color.text_secondary"))
      }
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
  }

  // 根据状态获取文本
  getStatusText() {
    switch (this.refreshStatus) {
      case RefreshStatus.Drag:
        return "继续下拉"
      case RefreshStatus.OverDrag:
        return "松手加载"
      case RefreshStatus.Refresh:
        return "加载中"
      default:
        return ""
    }
  }

  @Builder
  getRefreshDisplay() {
    // 状态 根据状态显示不同的文本
    Row({ space: 10 }) {
      LoadingProgress()
        .width(40)
        .aspectRatio(1)
        .color($r("app.color.primary"))
      Text(this.getStatusText())
        .fontSize(14)
        .fontColor($r("app.color.text_secondary"))
    }
    .justifyContent(FlexAlign.Center)
    .height(50)
    .width("100%")
  }

  build() {
    Refresh({ refreshing: $$this.refreshIng, builder: this.getRefreshDisplay }) {
      List() {
        ForEach(this.dataSource, (item: object) => {
          // 每一项的结构的UI内容不是由列表决定 而由使用者决定
          // 传入builderParam
          if (this.renderItem) {
            this.renderItem(item)
          }
        })
        // 最后放置提示文本的地方
        ListItem() {
          this.getBottomDisplay()
        }
      }
      .onReachEnd(async () => {
        // 实现上拉加载
        // 需要一个标记 是否已经加载完所有数据
        // 在没有加载完所有页数据的情况 且没有请求在进程中的情况下
        if (!this.finished && !this.loading) {
          this.loading = true // 关闭阀门
          await this.onLoad() // 实现上拉加载
          this.loading = false // 打开阀门
        }
      })

    }
    .onStateChange(async (state) => {
      this.refreshStatus = state // 记录状态
      // 实现下拉刷新
      if (state === RefreshStatus.Refresh) {
        // 松手加载
        await this.onRefresh() // 调用刷新方法
        this.refreshIng = false // 关闭下拉的动画效果
        this.loading = false // 关闭上拉刷新的loading
        // 下拉刷新意味着所有数据全都不要 重新来过

      }
    })

  }
}

export { ListComponents }