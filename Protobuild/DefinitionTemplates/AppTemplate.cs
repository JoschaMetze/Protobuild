using System.IO;

namespace Protobuild
{
    public class AppTemplate : BaseTemplate
    {
        public override string Type { get { return "App"; } }
        
        public override void WriteDefinitionFile(string name, Stream output)
        {
            using (var writer = new StreamWriter(output))
            {
                writer.Write(
@"<?xml version=""1.0"" encoding=""utf-8"" ?>
<Project
  Name=""" + name + @"""
  Path=""" + name + @"""
  Type=""Library"">
  <References>
    <Reference Include=""System"" />
    <Reference Include=""System.Core"" />
    <Reference Include=""Microsoft.CSharp"" />
  </References>
  <Files>
    <Compile Include=""MyClass.cs"" />
  </Files>
</Project>");
            }
        }
        
        public override void CreateFiles(string name, string projectRoot)
        {
            using (var writer = new StreamWriter(Path.Combine(projectRoot, "MyClass.cs")))
            {
                writer.Write(
@"using System;

namespace " + name + @"
{
    public class MyClass
    {
    }
}");
            }
        }
        
        public override string GetIcon()
        {
            return "ProtobuildManager.Images.application_osx.png";
        }
    }
}

