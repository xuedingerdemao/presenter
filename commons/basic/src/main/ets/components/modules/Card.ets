@Component
export struct Card {
  @BuilderParam
  CardParam: () => void

  build() {
    Column() {
      Column() {
        if (this.CardParam) {
          this.CardParam()
        }
      }
      .backgroundColor($r('app.color.white'))
      .borderRadius(10)
      .width('100%')
      .padding({
        left: 15,
        right: 15
      })
      .backgroundColor($r('app.color.white'))
    }.width('100%').padding(15)
  }
}