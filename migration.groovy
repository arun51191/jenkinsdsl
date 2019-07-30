import hudson.model.*
import jenkins.model.CauseOfInterruption
def src = build.buildVariableResolver.resolve("S_ENV")
def dest   = build.buildVariableResolver.resolve("D_ENV")
def database = build.buildVariableResolver.resolve("Database")                
print "\nSource database = ${src}\n\n"
print "Destination database = ${dest}\n\n"
print "Datbase name = ${database}\n\n"
print "Username = ${username}"
print "Password = ${password}"
if (src==dest) {
    def exec = build.getExecutor()
    def cause = { "source and target dbs are same" } as CauseOfInterruption 
    exec.interrupt(Result.ABORTED, cause)
}
