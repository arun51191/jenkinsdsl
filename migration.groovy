def src = System.getenv("S_ENV")
def dest   = System.getenv("D_ENV")
def database = System.getenv("Database")                
print "\nSource database = ${src}\n\n"
print "Destination database = ${dest}\n\n"
print "Datbase name = ${database}\n\n"
if(${src}==${dest}){
  error('Source and Destination environments should not be same')
}
