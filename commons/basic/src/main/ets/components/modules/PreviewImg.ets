@CustomDialog
@Component
struct PreviewImg {
  controller: CustomDialogController
  // 支持多张图片预览  给多张地址 给一个需要预览的索引
  urls: string[] = [] // 多张地址
  selectIndex:number = -1 // 当前索引
  build() {
    Column() {
       Swiper() {
         ForEach(this.urls, (url: string) => {
           Image(url)
             .width("100%") // 只给宽度 不给高度 让自己撑开
             .onClick(() => {
               this.controller.close()
             })
         })
       }
      .indicator(false) // 去掉点的显示
      .index(this.selectIndex) // 当前要看的是第几张图片

    }
    .justifyContent(FlexAlign.Center)
    .width("100%")
    .height("100%")
    .backgroundColor($r("app.color.black"))
  }
}
export { PreviewImg }