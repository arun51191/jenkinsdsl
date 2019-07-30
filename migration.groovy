import hudson.model.*
import jenkins.model.CauseOfInterruption
def src = build.buildVariableResolver.resolve("S_ENV")
def dest   = build.buildVariableResolver.resolve("D_ENV")
def database = build.buildVariableResolver.resolve("Database")                
print "\nSource database = ${src}\n\n"
print "Destination database = ${dest}\n\n"
print "Datbase name = ${database}\n\n"
if (src==dest||database=="") {
    def exec = build.getExecutor()
    def cause = { "source and target dbs are same or given empty database" } as CauseOfInterruption 
    exec.interrupt(Result.ABORTED, cause)
}

def env = System.getenv()
def credentials = "RADEV"
def source = "dev-hostname"
def target   = "dev-hostname"

if (src=="uat")
{
    credentials = "RAUAT"
    source      = "uat-hostname"
    
}

if (dest=="uat")
{
    credentials = "RAUAT"
    target      = "uat-hostname"
    
}

def pa1 = new ParametersAction([
  new StringParameterValue("env", credentials)
])

def pa2 = new ParametersAction([
  new StringParameterValue("env", source)
])

def pa3 = new ParametersAction([
  new StringParameterValue("env", target)
])

// add variable to current job
Thread.currentThread().executable.addAction(pa1)
Thread.currentThread().executable.addAction(pa2)
Thread.currentThread().executable.addAction(pa3)
