import { Card, CardItem, ConfirmDialog, TopNavBar, USER_TOKEN_KEY, UserTokenStore } from '@presenter/basic'
import { router } from '@kit.ArkUI'

@Entry
@Component
struct Setting {
  confirm: CustomDialogController = new CustomDialogController({
    builder: ConfirmDialog({
      message: '确定要退出登录吗?',
      buttonList: [{
        text: '取消'
      }, {
        text: '确定',
        fontColor: $r('app.color.primary'),
        action: () => {
          this.logout()
        }
      }]
    }),
    customStyle: true,
    alignment: DialogAlignment.Center,
    autoCancel: false
  })

  /*-----------------------👇👇 function 👇👇--------------------------------*/
  logout() {
    // 删除token
    AppStorage.set<string>(USER_TOKEN_KEY, "")
    new UserTokenStore(getContext(this)).setUserToken("")
    router.replaceUrl({
      url: 'pages/LoginPage/Login'
    })
  }

  build() {
    Column() {
      TopNavBar({ title: '个人设置' })
      Card() {
        CardItem({ leftTitle: '换绑手机', rightText: '' })
        CardItem({ leftTitle: '修改密码', rightText: '' })
        CardItem({ leftTitle: '消息通知设置', rightText: '' })
        CardItem({ leftTitle: '清理缓存', rightText: '', showBottomBorder: false })
      }

      Row() {
        Button("退出", { type: ButtonType.Normal })
          .backgroundColor($r('app.color.white'))
          .fontColor($r("app.color.text_primary"))
          .width('100%')
          .borderRadius(8)
          .height(60)
          .onClick(() => {
            this.confirm.open()
          })
      }
      .width('100%')
      .margin({
        top: 20
      })
      .padding({
        left: 15,
        right: 15
      })
      .justifyContent(FlexAlign.Center)

    }
    .padding({
      top: JSON.parse(AppStorage.get("topHeight")),
      bottom: JSON.parse(AppStorage.get('bottomHeight'))
    })
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_page'))
  }
}