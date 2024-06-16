import { Request } from '@presenter/basic'
import { LoginInfoModel, UserTaskInfoModel, UserTaskInfoParamsModel } from '../../models'
import { UserInfoModel } from '../../models/modules/UserInfoModel'

//获取用户登录信息--->token
const getLoginInfoAPI = (account: LoginInfoModel) => {
  return Request.post<string>("/login/account", account)
}


// 获取用户信息
const getUserInfoAPI = () => {
  return Request.get<UserInfoModel>("/users")
}
// 获取用户任务数据
const getUserTaskInfoAPI = (data: UserTaskInfoParamsModel) => {
  return Request.get<UserTaskInfoModel>("/users/taskReport", data)
}

export { getLoginInfoAPI, getUserInfoAPI, getUserTaskInfoAPI, }