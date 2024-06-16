@Preview
@Component
struct CheckBox {
  title: string = "测试"
  confirmText: string = "是"
  cancelText: string = '否'
  @Prop
  value: boolean = true // 决定左侧还是右侧\
  checkChange: (value: boolean) => void = () => {}
  build() {
   Row () {
     Row () {
      Text(this.title)
        .fontSize(14)
        .fontColor($r("app.color.text_primary"))

       // 右侧内容
       Row ({ space: 10 }) {
         Row () {
           Image(this.value ? $r("app.media.ic_radio_true") : $r("app.media.ic_radio_false"))
             .width(32)
             .aspectRatio(1)
           Text(this.confirmText)
         }
         .onClick(() => {
           this.value = true
           this.checkChange(this.value)
         })
         Row () {
           Image(!this.value ? $r("app.media.ic_radio_true") : $r("app.media.ic_radio_false"))
             .width(32)
             .aspectRatio(1)
           Text(this.cancelText)
         }
         .onClick(() => {
           this.value = false
           this.checkChange(this.value)
         })
       }
     }
     .width("100%")
     .borderRadius(10)
     .height(60)
     .padding({
       left: 15,
       right: 15
     })
     .justifyContent(FlexAlign.SpaceBetween)
     .backgroundColor($r("app.color.white"))

   }
    .width("100%")
    .padding({
      left: 15,
      right: 15
    })
    .margin({
      top: 15
    })
  }
}
export { CheckBox }