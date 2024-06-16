import { LoginInfo, LoginInfoModel } from '../../models'
import { promptAction, router } from '@kit.ArkUI'
import { getLoginInfoAPI } from '../../api'
import { USER_TOKEN_KEY, UserTokenStore } from '@presenter/basic'

@Entry
@Component
struct Login {
  appTitle: string = '标题标题啊'
  @State
  isLoading: boolean = false
  @State
  userLoginInfo: LoginInfoModel = new LoginInfoModel({
    account: 'toulao2',
    password: 'aabbcc',
  } as LoginInfo)
  @State
  loading: boolean = false // 控制进度条的显示
  photoRegExp: RegExp = /^(13[0-9]|14[01456879]|15[0-35-9]|16[2567]|17[0-8]|18[0-9]|19[0-35-9])\d{8}$/

  @Styles
  loginStyle() {
    .backgroundColor('#fff')
    .border({ color: $r('app.color.background_divider'), width: { bottom: 1 } })
    .width('100%')
    .height(58)
    .borderRadius(0)
  }

  /*---------------------------⬇⬇ function ⬇⬇--------------------------------------*/
  aboutToAppear(): void {
  }

  async getLoginInfo() {

    this.regExpFn()
    this.isLoading = true
    const res = await getLoginInfoAPI(this.userLoginInfo)
    await new UserTokenStore(getContext()).setUserToken(res)
    AppStorage.set(USER_TOKEN_KEY, res)
    this.isLoading = false
    router.replaceUrl({
      url: 'pages/Main/Index'
    })
    this.userLoginInfo.account = ''
    this.userLoginInfo.password = ''
  }

  isBtnEnable() {
    if (this.userLoginInfo.password && this.userLoginInfo.account) {
      return true
    }
    return false
  }

  //校验账号手机号
  regExpFn() {
    if (this.userLoginInfo.account === '') {
      promptAction.showToast({ message: '账号不能为空' })
      return
    }
    if (this.userLoginInfo.password === '') {
      promptAction.showToast({ message: '密码不能为空' })
      return
    }
    if (this.photoRegExp.test(this.userLoginInfo.account)) {
      promptAction.showToast({ message: '请输入正确的账号' })
      return
    }
    if (this.userLoginInfo.password.length < 6) {
      promptAction.showToast({ message: '密码不少于六位' })
      return
    }


  }

  build() {
    Column() {
      // 顶部标题
      Text(this.appTitle).fontColor($r('app.color.text_primary')).fontSize(18).height(25)
      // 账号登录
      Row() {
        Text('账号登录').fontColor($r('app.color.text_primary')).fontSize(24).fontWeight(FontWeight.Bold)
        Row() {
          Text("账号登录").fontColor($r('app.color.primary')).fontSize(16).fontWeight(FontWeight.Bold)
          Image($r("app.media.ic_angle")).width(10).height(10).margin({ left: 5 })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 50, bottom: 50 })

      // 用户名输入框
      TextInput({ placeholder: '请输入账号', text: this.userLoginInfo.account })
        .loginStyle()
        .focusable(true)//聚焦
        .defaultFocus(true)//聚焦
        .id('accountInput')
        .onChange((val) => {
          this.userLoginInfo.account = val
        })
        .onSubmit(() => {
          if (this.userLoginInfo.account === '') {
            promptAction.showToast({ message: '账号不能为空' })
            return
          }
          // focusControl.requestFocus('accountInput')
        })


      // 密码框
      TextInput({ placeholder: '请输入密码', text: this.userLoginInfo.password })
        .loginStyle()
        .type(InputType.Password)// 密码框
        .showPasswordIcon(true)// 显示密码按钮
        .focusable(true)//聚焦
        .defaultFocus(true)//聚焦
        .id('PasswordInput')
        .onChange((val) => {
          this.userLoginInfo.password = val
        })
        .onSubmit(() => {
          this.regExpFn()
          // focusControl.requestFocus('PasswordInput')
        })
      // 登录按钮
      Button({ type: ButtonType.Capsule }) {
        Row() {
          if (this.isLoading) {
            LoadingProgress().width(20).height(20).margin({ right: 12 }).color($r('app.color.white'))
          }
          Text('登录').fontColor($r('app.color.white'))
        }
      }
      .backgroundColor($r('app.color.primary'))
      .width('100%')
      .height(50)
      .margin({ top: 50 })
      .enabled(this.isBtnEnable())
      .onClick(() => {
        this.getLoginInfo()
        // this.regExpFn()
      })

    }
    .padding({ left: 32, right: 32 })
    .margin({ top: 40 })
  }
}