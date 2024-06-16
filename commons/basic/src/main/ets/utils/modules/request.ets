import http from '@ohos.net.http'; // 原生的请求地址
import { promptAction, router } from '@kit.ArkUI';
import { BASE_URL, USER_TOKEN_KEY } from '../../constants';
import { ResponseData } from '../../models/modules/ApiModels';
import { UserTokenStore } from '..';


async function requestHttp<T>(url: string = "", method: http.RequestMethod = http.RequestMethod.GET,
  data?: object): Promise<T> {
  // http需要创建一个请求对象
  const httpRequest = http.createHttp() // 创建一个请求对象- 如果你想用单例 那么请不要在请求时销毁
  let urlStr = BASE_URL + url // 基础地址拼接url地址


  // 官方文档上 如果get类型会进行拼接地址，但是实际并没有
  if (method === http.RequestMethod.GET) {
    if (data && Object.keys(data).length) {
      urlStr += "?" + Object.keys(data).filter(key =>!!data[key]).map(key => {
        return `${key}=${data[key]}`
      }).join("&")
    }
  }
  // 组装参数
  const config: http.HttpRequestOptions = {
    extraData: method !== http.RequestMethod.GET ? data : "", // 当请求类型不等于get时 复制
    header: {
      "Content-Type": "application/json",
      Authorization: AppStorage.get(USER_TOKEN_KEY) || "", // 设置请求头的token 每个接口都有
    },
    method,
    readTimeout: 10000 // 如果多少秒没响应就断开
  }
  try {
    // 发请求
    const result = await httpRequest.request(urlStr, config) // 发请求
    // 这里要处理一些异常
    // 判断状态码 http状态码 业务状态码
    if (result.responseCode === 401) {
      // 401 就表示token失效 超时 或者没传
      promptAction.showToast({ message: '登录失效' })
      // 删除token - 删两个地址 首选项- 全局状态
      new UserTokenStore(getContext()).setUserToken("") // 清空首选项token
      AppStorage.set(USER_TOKEN_KEY, "") // 只能设置 不能删除
      router.replaceUrl({
        url: 'pages/Login/Login' // 跳转到登录页
      })
      // Hap har
      return Promise.reject(new Error("登录失效"))
    } else if (result.responseCode === 404) {
      promptAction.showToast({ message: '请求地址错误' })
      return Promise.reject(new Error("请求地址错误"))
    } else {
      // 假设已经成功   只有业务状态码 200的时候才成功
      const res = JSON.parse(result.result as string) as ResponseData<T> // { code, data, msg }
      if (res.code === 200) {
        // 才认为这次请求真的成功了
        return res.data as T
      } else {
        // 业务错了
        promptAction.showToast({ message: "服务器异常" })
        return Promise.reject(new Error(res.msg)) // 业务错误 请求终止
      }
    }
  } catch (error) {
    promptAction.showToast({ message: error.message })
    return Promise.reject(error) // 业务错误 请求终止
  }

}

export class Request {
  static get<T>(url: string, data?: object): Promise<T> {
    return requestHttp<T>(url, http.RequestMethod.GET, data)
  }

  static post<T>(url: string, data?: object): Promise<T> {
    return requestHttp<T>(url, http.RequestMethod.POST, data)
  }

  static delete<T>(url: string, data?: object): Promise<T> {
    return requestHttp<T>(url, http.RequestMethod.DELETE, data)
  }

  static put<T>(url: string, data?: object): Promise<T> {
    return requestHttp<T>(url, http.RequestMethod.PUT, data)
  }
}
