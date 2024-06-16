import { preferences } from '@kit.ArkData'
import { USER_TOKEN_KEY, USER_TOKEN_STORE } from '../../constants'
import { promptAction } from '@kit.ArkUI'

export class UserTokenStore {
  context: Context

  constructor(context: Context) {
    this.context = context
  }

  initStore() {
    return preferences.getPreferencesSync(this.context, { name: USER_TOKEN_STORE })
  }

  async setUserToken(token: string) {
    const store = this.initStore()

    store.putSync(USER_TOKEN_KEY, token)

    await store.flush()
  }

  getUserToken() {
    const store = this.initStore()
    return store.getSync(USER_TOKEN_KEY, '') as string
  }

  //删除用户的token
  async delUserToken() {
    const store = this.initStore()
    promptAction.showDialog({ message: JSON.stringify(store) })
    store.deleteSync(USER_TOKEN_KEY)
    //写入磁盘
    await store.flush()
  }

  // 删除整个token仓库
  async delAllToken() {
    preferences.deletePreferences(this.context, { name: USER_TOKEN_STORE })
  }
}
