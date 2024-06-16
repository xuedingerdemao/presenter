import { AdvertClass, UserAdvSettingClass } from '@presenter/basic/Index'
import { promptAction, window } from '@kit.ArkUI'
import { ADV_WIN } from '../../constants/AdvConstants'

@Entry
@Component
struct Start {
  userSetting: UserAdvSettingClass = new UserAdvSettingClass(getContext(this))
  @State
  adObj: AdvertClass = {
    showAd: false,
    adTime: 0
  }
  timer: number = -1

  //关闭窗口清除定时器
  aboutToDisappear(): void {
    this.clearTimer()
  }

  closeWin() {
    //找到对应的window，然后销毁
    window.findWindow(ADV_WIN).destroyWindow()
    promptAction.showToast({ message: '1111' })
  }

  // 清除定时器
  clearTimer() {
    clearInterval(this.timer)
  }

  async aboutToAppear() {
    this.adObj = await this.userSetting.getAdvStore()
    this.timer = setInterval(() => {
      if (this.adObj.adTime === 0) {
        clearInterval(this.timer)
        this.closeWin()
        return
      }
      this.adObj.adTime--
    }, 1000)
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Image(this.adObj.adImg).objectFit(ImageFit.Fill)
      Text(`${this.adObj.adTime}秒后跳过`)
        .padding({ left: 10, right: 10 })
        .margin({ right: 20, top: JSON.parse(AppStorage.get("topHeight")) })
        .height(30)
        .fontSize(14)
        .borderRadius(15)
        .backgroundColor($r("app.color.background_page"))
        .textAlign(TextAlign.Center)
        .onClick(() => {
          this.closeWin()
        })


    }
    .height('100%')
    .width('100%')
  }
}
