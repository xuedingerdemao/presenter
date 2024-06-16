export const DateFormat = (value: Date) => {
  return value.getFullYear() + "-" + (value.getMonth() + 1).toString().padStart(2, "0") + '-'
    + value.getDate().toString().padStart(2, "0") + " " +
  value.getHours().toString().padStart(2, "0") + ":"
    + value.getMinutes().toString().padStart(2, "0")
}