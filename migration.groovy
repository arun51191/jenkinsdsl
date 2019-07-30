import hudson.model.*
def src = System.getenv("S_ENV")
def dest   = System.getenv("D_ENV")
def database = System.getenv("Database")                
print "\nSource database = ${src}\n\n"
print "Destination database = ${dest}\n\n"
print "Datbase name = ${database}\n\n"
def autoCancelled = false

try {
    if (${src}==${dest}) {
      autoCancelled = true
      error('Aborting the build.')
    }
  }
 catch (e) {
  if (autoCancelled) {
    currentBuild.result = 'SUCCESS'
    // return here instead of throwing error to keep the build "green"
    return
  }
  // normal error handling
  throw e
}
