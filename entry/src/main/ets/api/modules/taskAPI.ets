import { Request } from '@presenter/basic'
import {
  CarRecordTypeModel,
  DelayParamsTypeModel,
  DeliverParamsTypeModel,
  ExceptionParamsTypeModel,
  PickUpParamsModel,
  TaskDetailInfoModel,
  TaskListDataModel,
  TaskListParamsModel
} from '../../models'

// 获取用户任务列表
export const getTaskListAPI = (params: TaskListParamsModel) => {
  return Request.get<TaskListDataModel>("/tasks/list", params)
}

// 获取用户任务详情
export const getTaskDetailAPI = (id: string) => {
  return Request.get<TaskDetailInfoModel>(`/tasks/details/${id}`)
}

// 提货
export const pickUpAPI = (params: PickUpParamsModel) => {
  return Request.post<null>(`/tasks/takeDelivery`, params)
}

// 提货
export const deliverAPI = (params: DeliverParamsTypeModel) => {
  return Request.post<null>(`/tasks/deliver`, params)
}

// 回车登记
export const carRecordAPI = (params: CarRecordTypeModel) => {
  return Request.post<null>(`/tasks/truckRegistration`, params)
}

// 延迟提货
export const delayAPI = (params: DelayParamsTypeModel) => {
  return Request.put<null>(`/tasks/delay`, params)
}

// 上报异常
export const exceptionReportAPI = (params: ExceptionParamsTypeModel) => {
  return Request.post<null>(`/tasks/reportException`, params)
}
