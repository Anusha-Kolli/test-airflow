import re,sys

def changelog_data():
  f= open('CHANGELOG.md', "r")
  keepCurrentSet = False
  for line in f:
      if line.startswith("## [8.18.5]"):
          keepCurrentSet = False
      if keepCurrentSet:
          print (line, end="")
      if line.startswith("## [Unreleased]"):
          keepCurrentSet = True
  return(line)

   
if __name__ == "__main__":
    changelog_data()