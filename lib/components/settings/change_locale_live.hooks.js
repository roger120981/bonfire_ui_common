function date_future(days) {
  let date = new Date()
  // Set expiry to X days
  date.setDate(date.getDate() + days)
  return date.toGMTString()
}

export default {
  destroyed() {
    console.log(this.el.value)
    document.cookie = `locale=${this.el.value}; path=/; expires=${date_future(90)}`
    // Cookie.set("locale", this.el.value)
  }
}