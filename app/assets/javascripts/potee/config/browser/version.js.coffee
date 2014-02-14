#= require jquery.browser/dist/jquery.browser

do () ->

  minimalBrowserVersions =
    chrome  : 30
    firefox : 27
    opera   : 12.5
    safari  : 6
    msie    : 11

  alertVersionError = (minVersion, browser) ->
    browser = browser.substring(0, 1).toUpperCase() + browser.substring(1, browser.length)

    alert """
      Your browser #{browser} older than minimum required version #{minVersion}. 
      Please upgrade to the latest version of your browser
    """

  # Chrome version checking
  if $.browser.chrome is true and
     $.browser.versionNumber < minimalBrowserVersions.chrome

    alertVersionError(minimalBrowserVersions.chrome, $.browser.name)

  # Firefox version checking
  if $.browser.mozilla is true and
     $.browser.versionNumber < minimalBrowserVersions.firefox

    alertVersionError(minimalBrowserVersions.firefox, $.browser.name)

  # Opera version checking
  if $.browser.opera is true and
     $.browser.versionNumber < minimalBrowserVersions.opera

    alertVersionError(minimalBrowserVersions.opera, $.browser.name)

  # Safari version checking
  if $.browser.safari is true and
     $.browser.versionNumber < minimalBrowserVersions.safari

    alertVersionError(minimalBrowserVersions.safari, $.browser.name)

  # Safari version checking
  if $.browser.msie is true and
     $.browser.versionNumber < minimalBrowserVersions.msie

    alertVersionError(minimalBrowserVersions.msie, $.browser.name)