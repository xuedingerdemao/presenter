import { Card, CardItem, DateFormat, TopNavBar, Upload } from '@presenter/basic'
import { router } from '@kit.ArkUI'
import { CommonRouterParams, ExceptionParamsType, ExceptionParamsTypeModel } from '../../models'

@Entry
@Component
struct Report {
  @State
  exceptionForm: ExceptionParamsTypeModel = new ExceptionParamsTypeModel({} as ExceptionParamsType)

  /*-----------------------👇👇 function 👇👇--------------------------------*/
  aboutToAppear() {
    const params = router.getParams() as CommonRouterParams
    if (params && params.id) {
      this.exceptionForm.transportTaskId = params.id
    }
  }

  build() {
    Column() {
      TopNavBar({ title: '上报异常' })
      Scroll() {
        Column() {
          Card() {
            CardItem({
              leftTitle: '异常时间',
              rightText: '请选择',
              onRightClick: () => {
                DatePickerDialog.show({
                  showTime: true,
                  useMilitaryTime: true,
                  onDateAccept: (value) => {
                    this.exceptionForm.exceptionTime = DateFormat(value)
                  }
                })
              }
            })
            CardItem({
              leftTitle: '上报位置',
              rightText: '请选择',
            })
            CardItem({
              leftTitle: '异常类型',
              rightText: '请选择',
            })
            CardItem({
              leftTitle: '异常描述',
              rightText: '',
              showRightIcon: false,
              showBottomBorder: false
            })
            TextArea({
              placeholder: '请输入异常描述'
            }).height(130).borderRadius(8).placeholderColor($r('app.color.text_secondary')).fontSize(14)
            Text(`0/50`)
              .margin({
                top: -30
              })
              .textAlign(TextAlign.End)
              .width('100%')
              .padding({ right: 15 })
              .fontColor($r('app.color.text_secondary'))
            Row().height(20)

          }

          Card() {
            Upload({
              title: '上传图片(最多6张)',
              imgList: []
            , canUpload: true
            })
            Row().height(20)
          }
        }
      }.padding({
        bottom: 80
      })
      .layoutWeight(1)


      Row() {
        Button("提交").height(50).width(207).backgroundColor($r('app.color.primary_disabled'))
      }
      .position({
        y: '100%'
      })
      .height(70)
      .translate({
        y: -70
      })
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.white'))
    }
    .height('100%').backgroundColor($r('app.color.background_page'))
  }
}