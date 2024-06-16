import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { getAdvAPI, USER_TOKEN_KEY, UserAdvSettingClass, UserTokenStore } from '@presenter/basic/Index';
import { ADV_WIN } from '../constants/AdvConstants';
import Window from '@ohos.window';

export default class EntryAbility extends UIAbility {
  sec: number = 0
  stage?: window.WindowStage
  private isShowAdv: boolean = false
  private timer: number = -1
  private maxSec: number = 10

  goBack() {
    this.timer = setInterval(() => {
      if (this.sec === this.maxSec) {
        clearInterval(this.timer)
        this.isShowAdv = true
        return
      }
      this.sec++
    }, 1000)

  }

  goFore() {
    if (this.isShowAdv) {
      this.isShowAdv = false
      this.sec = 0
      clearInterval(this.timer)
      return true
    }
    return false
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    this.stage = windowStage
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    //初始化广告仓库
    const advStore = new UserAdvSettingClass(this.context)
    const userTokenStore = new UserTokenStore(this.context)

    // 设置全屏 沉浸式
    const win = await windowStage.getMainWindowSync()
    win.setWindowLayoutFullScreen(true)
    const topHeight = await win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect.height
    const bottomHeight = await win.getWindowAvoidArea(Window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR).bottomRect.height
    AppStorage.setOrCreate("topHeight", px2vp(topHeight))
    AppStorage.setOrCreate("bottomHeight", px2vp(bottomHeight))
    //加载广告
    const resAdv = await getAdvAPI()
    await advStore.setAdvStore(resAdv) // 写入首选项
    //如果有创建广告窗口
    if (resAdv.showAd) {
      const win = await windowStage.createSubWindow(ADV_WIN)
      //展示窗口
      await win.showWindow()
      //展示广告窗口
      win.setUIContent('pages/StartAdv/Start')
      console.log('1111🥳', '----->👉', 1111);
    }
    //get userToken
    const getTokenStore = userTokenStore.getUserToken()
    const userToken = getTokenStore || ''
    AppStorage.setOrCreate(USER_TOKEN_KEY, userToken)
    if (userToken) {
      windowStage.loadContent('pages/Main/Index');
    } else {
      windowStage.loadContent('pages/LoginPage/Login');
    }


  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources

    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  async onForeground(): Promise<void> {
    // Ability has brought to foreground
    // new cutForeOrBack().goFore()
    // let isShow = this.goFore()
    //
    // if (isShow) {
    //   const win = await this.stage?.createSubWindow(ADV_WIN)
    //   await win?.showWindow()
    //   //展示广告窗口
    //   win?.setUIContent('pages/StartAdv/Start')
    //   console.log('11111🥳', '----->👉', 11111);
    // }
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    // this.goBack()
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
