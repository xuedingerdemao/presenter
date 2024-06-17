import { promptAction, router } from '@kit.ArkUI'
import { Card, CardItem, CommonRouterParams, DateFormat, TopNavBar } from '@presenter/basic'
import { delayAPI } from '../../api/modules/taskAPI'
import { DelayParamsType, DelayParamsTypeModel } from '../../models'

@Entry
@Component
struct Delay {
  @State
  delayForm: DelayParamsTypeModel = new DelayParamsTypeModel({} as DelayParamsType)
  @State
  oldTime: string = ""

  aboutToAppear(): void {
    const params = router.getParams() as CommonRouterParams
    if (params.oldTime) {
      this.oldTime = params.oldTime
    }
    if (params.id) {
      this.delayForm.id = params.id
    }
  }

  getBtnEnable() {
    if (this.delayForm.id
      && this.delayForm.delayReason && this.delayForm.delayTime) {
      return true
    }
    return false
  }

  async btnDelay() {
    await delayAPI(this.delayForm)
    promptAction.showToast({ message: '延迟提货成功' })
    router.back()
  }

  build() {
    Column() {
      TopNavBar({ title: '延迟提货' })
      Card() {
        CardItem({ leftTitle: '原定时间', rightText: this.oldTime, showRightIcon: false })
        CardItem({
          leftTitle: '延迟时间', rightText: this.delayForm.delayTime || '',
          onRightClick: () => {
            DatePickerDialog.show({
              useMilitaryTime: true,
              showTime: true,
              onDateAccept: (value) => {
                this.delayForm.delayTime = DateFormat(value)
              }
            })
          }
        })
        TextArea({
          placeholder: '请输入延迟提货原因', text: this.delayForm.delayReason
        })
          .maxLength(50)
          .onChange(value => {
            this.delayForm.delayReason = value
          })
          .backgroundColor($r('app.color.background_page'))
          .margin({
            top: 20
          })
          .borderRadius(8)
          .height(130)
          .placeholderColor($r('app.color.text_secondary'))
          .fontSize(14)
        Text(`${this.delayForm.delayReason?.length || 0}/50`)
          .margin({
            top: -30
          })
          .textAlign(TextAlign.End)
          .width('100%')
          .padding({ right: 15 })
          .fontColor($r('app.color.text_secondary'))
        Row() {
          Button("提交")
            .height(50)
            .width(207)
            .backgroundColor($r('app.color.primary'))
            .enabled(this.getBtnEnable())
            .onClick(() => {
              this.btnDelay()
            })
        }.justifyContent(FlexAlign.Center).padding({
          top: 20,
          bottom: 20
        })

      }
    }
    .padding({
      top: JSON.parse(AppStorage.get("topHeight")),
      bottom: JSON.parse(AppStorage.get('bottomHeight'))
    })
    .height('100%')
    .backgroundColor($r('app.color.background_page'))
  }
}