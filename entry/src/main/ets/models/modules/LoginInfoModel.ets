export interface LoginInfo {
  /** 登录账号 */
  account: string;

  /** 登录密码 */
  password: string;
}

export class LoginInfoModel implements LoginInfo {
  account: string = ''
  password: string = ''

  constructor(model: LoginInfo) {
    this.account = model.account
    this.password = model.password
  }
}
