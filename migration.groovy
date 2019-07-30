import hudson.model.*
import hudson.AbortException
import hudson.console.HyperlinkNote
import java.util.concurrent.CancellationException
def src = System.getenv("S_ENV")
def dest   = System.getenv("D_ENV")
def database = System.getenv("Database")                
print "\nSource database = ${src}\n\n"
print "Destination database = ${dest}\n\n"
print "Datbase name = ${database}\n\n"
def autoCancelled = false

assert ${src}==${dest} : "Source and target should be different"
