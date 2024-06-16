@Preview
@CustomDialog
@Component
struct SelectCard {
  controller: CustomDialogController
  title: string = "请选择"
  showClose: boolean = true // 是否显示关闭按钮
  showButton: boolean = true // 是否显示底部按钮
  buttonText: string = "确定"
  // 参数接收内部要渲染的UI结构
  @BuilderParam
  cardContent: () => void

  confirm: () => void = () => {
  } // 点击确定事件

  build() {
    Column() {
      Row() {
        Text(this.title).fontSize(16).fontColor($r('app.color.text_primary'))
        if (this.showClose) {
          Image($r("app.media.ic_btn_close")).width(13).height(13)
            .onClick(() => {
              this.controller.close() // 关闭弹层
            })
        }
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .width('100%')
      .height(60)
      .borderRadius({
        topLeft: 16,
        topRight: 16
      })

      if (this.cardContent) {
        this.cardContent() // 渲染传入的内容
      }
      // 渲染内容
      if (this.showButton) {
        Row() {
          Button(this.buttonText, { type: ButtonType.Capsule })
            .width(200)
            .height(45)
            .backgroundColor($r('app.color.primary'))
            .onClick(() => {
              this.confirm() // 调用确定事件
            })
        }.width('100%').justifyContent(FlexAlign.Center)
      }
    }

    .justifyContent(FlexAlign.SpaceBetween).padding({
      left: 21.36,
      right: 21.36
    })
    .backgroundColor($r('app.color.white'))
  }
}

export { SelectCard }