module.exports.timeAgoFromMs = (ms) ->
  sec = Math.round(ms / 1000)
  min = Math.round(sec / 60)
  hr = Math.round(min / 60)
  day = Math.round(hr / 24)
  month = Math.round(day / 30)
  year = Math.round(month / 12)
  if ms < 0
    'just now'
  else if sec < 10
    'just now'
  else if sec < 45
    sec + ' seconds ago'
  else if sec < 90
    'a minute ago'
  else if min < 45
    min + ' minutes ago'
  else if min < 90
    'an hour ago'
  else if hr < 24
    hr + ' hours ago'
  else if hr < 36
    'a day ago'
  else if day < 30
    day + ' days ago'
  else if day < 45
    'a month ago'
  else if month < 12
    month + ' months ago'
  else if month < 18
    'a year ago'
  else
    year + ' years ago'

module.exports.debounce = (func, wait, immediate) ->
  timeout = undefined
  ->
    context = this
    args = arguments

    later = ->
      timeout = null
      func.apply context, args unless immediate
      return

    callNow = immediate and not timeout
    clearTimeout timeout
    timeout = setTimeout(later, wait)
    func.apply context, args if callNow
    return
