<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:msxsl="urn:schemas-microsoft-com:xslt"
  xmlns:user="urn:my-scripts"
  exclude-result-prefixes="xsl msxsl user"
  version="1.0">

  <xsl:output method="xml" indent="no" />

  <msxsl:script language="C#" implements-prefix="user">
    <msxsl:assembly name="System.Web" />
    <msxsl:using namespace="System" />
    <msxsl:using namespace="System.Web" />
    <![CDATA[
    public string NormalizeXAPName(string origName)
    {
      return origName.Replace('.','_');
    }
    public string GetRelativePath(string from, string to)
    {
      try
      {
        var current = Environment.CurrentDirectory;
        from = System.IO.Path.Combine(current, from.Replace('\\', '/'));
        to = System.IO.Path.Combine(current, to.Replace('\\', '/'));
        return (new Uri(from).MakeRelativeUri(new Uri(to)))
          .ToString().Replace('/', '\\');
      }
      catch (Exception ex)
      {
        return ex.Message;
      }
    }
    
    public bool ProjectIsActive(string platformString, string activePlatform)
    {
      if (string.IsNullOrEmpty(platformString))
      {
        return true;
      }
      var platforms = platformString.Split(',');
      foreach (var i in platforms)
      {
        if (i == activePlatform)
        {
          return true;
        }
      }
      return false;
    }
    ]]>
  </msxsl:script>

  <xsl:template name="profile_and_version"
    xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
    <xsl:choose>
      <xsl:when test="/Input/Properties/FrameworkVersions
                      /Platform[@Name=/Input/Generation/Platform]
                      /Version">
        <xsl:choose>
          <xsl:when test="/Input/Generation/Platform = 'Windows8'">
            <TargetPlatformVersion>
              <xsl:value-of select="/Input/Properties/FrameworkVersions
                                                      /Platform[@Name=/Input/Generation/Platform]
                                                      /Version" />
            </TargetPlatformVersion>
          </xsl:when>
          <xsl:otherwise>
        <TargetFrameworkVersion>
          <xsl:value-of select="/Input/Properties/FrameworkVersions
                                                      /Platform[@Name=/Input/Generation/Platform]
                                                      /Version" />
        </TargetFrameworkVersion>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="/Input/Properties/FrameworkVersions/Version">
        <TargetFrameworkVersion>
          <xsl:value-of select="/Input/Properties/FrameworkVersions/Version" />
        </TargetFrameworkVersion>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="/Input/Generation/Platform = 'Android'">
            <TargetFrameworkVersion>v4.2</TargetFrameworkVersion>
          </xsl:when>
          <xsl:when test="/Input/Generation/Platform = 'Ouya'">
            <TargetFrameworkVersion>v4.1</TargetFrameworkVersion>
          </xsl:when>
          <xsl:when test="/Input/Generation/Platform = 'Windows8'">
            
          </xsl:when>
          <xsl:when test="/Input/Generation/Platform = 'WindowsPhone'">
            <TargetFrameworkVersion>v8.0</TargetFrameworkVersion>
            <TargetFrameworkIdentifier>WindowsPhone</TargetFrameworkIdentifier>
          </xsl:when>
          <xsl:when test="/Input/Generation/Platform = 'iOS'">
          </xsl:when>
          <xsl:otherwise>
            <TargetFrameworkVersion>v4.0</TargetFrameworkVersion>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="/Input/Properties/FrameworkVersions
                      /Platform[@Name=/Input/Generation/Platform]
                      /Profile">
        <TargetFrameworkProfile>
          <xsl:value-of select="/Input/Properties/FrameworkVersions
                                                      /Platform[@Name=/Input/Generation/Platform]
                                                      /Profile" />
        </TargetFrameworkProfile>
      </xsl:when>
      <xsl:when test="/Input/Properties/FrameworkVersions/Profile">
        <TargetFrameworkProfile>
          <xsl:value-of select="/Input/Properties/FrameworkVersions/Profile" />
        </TargetFrameworkProfile>
      </xsl:when>
      <xsl:otherwise>
        <TargetFrameworkProfile></TargetFrameworkProfile>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="configuration"
    xmlns="http://schemas.microsoft.com/developer/msbuild/2003">

    <xsl:param name="project" />
    <xsl:param name="debug" />
    <xsl:choose>
      <xsl:when test="$debug = 'true'">
        <DebugSymbols>true</DebugSymbols>
        <Optimize>false</Optimize>
      </xsl:when>
      <xsl:otherwise>
        <Optimize>true</Optimize>
      </xsl:otherwise>
    </xsl:choose>
    <DebugType>full</DebugType>
    <OutputPath>
      <xsl:choose>
        <xsl:when test="msxsl:node-set($project)/@Type = 'Website'">
          <xsl:text>bin</xsl:text>
        </xsl:when>
        <xsl:when test="/Input/Properties/PlatformOutput">
          <xsl:choose>
            <xsl:when test="$debug = 'true'">
              <xsl:value-of select="concat(
                                'bin/',
                                /Input/Generation/Platform,
                                '/Debug')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat(
                                'bin/',
                                /Input/Generation/Platform,
                                '/Release')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$debug = 'true'">
              <xsl:text>bin\Debug</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>bin\Release</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </OutputPath>
    <DefineConstants>
      <xsl:if test="$debug = 'true'">
        <xsl:text>DEBUG;</xsl:text>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="/Input/Properties/CustomDefinitions">
          <xsl:for-each select="/Input/Properties/CustomDefinitions/Platform">
            <xsl:if test="/Input/Generation/Platform = ./@Name">
              <xsl:value-of select="." />
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="/Input/Generation/Platform = 'Android'">
              <xsl:text>PLATFORM_ANDROID</xsl:text>
            </xsl:when>
            <xsl:when test="/Input/Generation/Platform = 'iOS'">
              <xsl:text>PLATFORM_IOS</xsl:text>
            </xsl:when>
            <xsl:when test="/Input/Generation/Platform = 'Linux'">
              <xsl:text>PLATFORM_LINUX</xsl:text>
            </xsl:when>
            <xsl:when test="/Input/Generation/Platform = 'MacOS'">
              <xsl:text>PLATFORM_MACOS</xsl:text>
            </xsl:when>
            <xsl:when test="/Input/Generation/Platform = 'Ouya'">
              <xsl:text>PLATFORM_OUYA</xsl:text>
            </xsl:when>
            <xsl:when test="/Input/Generation/Platform = 'PSMobile'">
              <xsl:text>PLATFORM_PSMOBILE</xsl:text>
            </xsl:when>
            <xsl:when test="/Input/Generation/Platform = 'Windows'">
              <xsl:text>PLATFORM_WINDOWS</xsl:text>
            </xsl:when>
            <xsl:when test="/Input/Generation/Platform = 'Windows8'">
              <xsl:text>PLATFORM_WINDOWS8</xsl:text>
            </xsl:when>
            <xsl:when test="/Input/Generation/Platform = 'WindowsGL'">
              <xsl:text>PLATFORM_WINDOWSGL</xsl:text>
            </xsl:when>
            <xsl:when test="/Input/Generation/Platform = 'WindowsPhone'">
              <xsl:text>PLATFORM_WINDOWSPHONE</xsl:text>
            </xsl:when>
          </xsl:choose>
          <xsl:text>;</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </DefineConstants>
    <ErrorReport>prompt</ErrorReport>
    <WarningLevel>4</WarningLevel>
    <xsl:choose>
      <xsl:when test="/Input/Properties/ForceArchitecture">
        <PlatformTarget>
          <xsl:value-of select="/Input/Properties/ForceArchitecture" />
        </PlatformTarget>
      </xsl:when>
    </xsl:choose>
    <!--<xsl:call-template name="profile_and_version" />-->
    <xsl:choose>
      <xsl:when test="/Input/Generation/Platform = 'Android'">
        <xsl:choose>
          <xsl:when test="$debug = 'true'">
            <MonoDroidLinkMode>None</MonoDroidLinkMode>
            <AndroidLinkMode>None</AndroidLinkMode>
          </xsl:when>
          <xsl:otherwise>
            <AndroidUseSharedRuntime>False</AndroidUseSharedRuntime>
            <!--<AndroidLinkMode>SdkOnly</AndroidLinkMode>-->
            <EmbedAssembliesIntoApk>True</EmbedAssembliesIntoApk>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="/Input/Generation/Platform = 'iOS'">
        <xsl:choose>
          <xsl:when test="$debug = 'true'">
            <CheckForOverflowUnderflow>True</CheckForOverflowUnderflow>
            <AllowUnsafeBlocks>True</AllowUnsafeBlocks>
            <MtouchDebug>True</MtouchDebug>
            <MtouchUseArmv7>false</MtouchUseArmv7>
          </xsl:when>
          <xsl:otherwise>
            <MtouchUseArmv7>false</MtouchUseArmv7>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="/Input/Generation/Platform = 'MacOS'">
        <EnableCodeSigning>False</EnableCodeSigning>
        <CreatePackage>False</CreatePackage>
        <EnablePackageSigning>False</EnablePackageSigning>
        <IncludeMonoRuntime>False</IncludeMonoRuntime>
        <UseSGen>False</UseSGen>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="/">

    <xsl:variable
      name="project"
      select="/Input/Projects/Project[@Name=/Input/Generation/ProjectName]" />

    <Project
      DefaultTargets="Build"
      ToolsVersion="4.0"
      xmlns="http://schemas.microsoft.com/developer/msbuild/2003">

      <PropertyGroup>
        <Configuration Condition=" '$(Configuration)' == '' ">Debug</Configuration>
        <xsl:choose>
          <xsl:when test="/Input/Properties/ForceArchitecture">
            <Platform Condition=" '$(Platform)' == '' ">
              <xsl:value-of select="/Input/Properties/ForceArchitecture" />
            </Platform>
          </xsl:when>
          <xsl:otherwise>
            <Platform Condition=" '$(Platform)' == '' ">AnyCPU</Platform>
          </xsl:otherwise>
        </xsl:choose>
        <ProductVersion>10.0.0</ProductVersion>
        <SchemaVersion>2.0</SchemaVersion>
        <ProjectGuid>
          {<xsl:value-of select="$project/@Guid" />}
        </ProjectGuid>
        <xsl:choose>
          <xsl:when test="$project/@Type = 'Website'">
            <ProjectTypeGuids>
              <xsl:text>{349C5851-65DF-11DA-9384-00065B846F21};</xsl:text>
              <xsl:text>{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}</xsl:text>
            </ProjectTypeGuids>
          </xsl:when>
          <xsl:when test="/Input/Generation/Platform = 'Android'">
            <ProjectTypeGuids>
              <xsl:text>{EFBA0AD7-5A72-4C68-AF49-83D382785DCF};</xsl:text>
              <xsl:text>{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}</xsl:text>
            </ProjectTypeGuids>
          </xsl:when>
          <xsl:when test="/Input/Generation/Platform = 'iOS'">
            <ProjectTypeGuids>
              <xsl:text>{6BC8ED88-2882-458C-8E55-DFD12B67127B};</xsl:text>
              <xsl:text>{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}</xsl:text>
            </ProjectTypeGuids>
          </xsl:when>
          <xsl:when test="/Input/Generation/Platform = 'PSMobile'">
            <ProjectTypeGuids>
              <xsl:text>{69878862-DA7D-4DC6-B0A1-50D8FAB4242F};</xsl:text>
              <xsl:text>{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}</xsl:text>
            </ProjectTypeGuids>
          </xsl:when>
          <xsl:when test="/Input/Generation/Platform = 'Windows8'">
            <ProjectTypeGuids>
              <xsl:text>{BC8A1FFA-BEE3-4634-8014-F334798102B3};</xsl:text>
              <xsl:text>{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}</xsl:text>
            </ProjectTypeGuids>
          </xsl:when>
          <xsl:when test="/Input/Generation/Platform = 'WindowsPhone'">
            <ProjectTypeGuids>
              <xsl:text>{C089C8C0-30E0-4E22-80C0-CE093F111A43};</xsl:text>
              <xsl:text>{fae04ec0-301f-11d3-bf4b-00c04f79efbc}</xsl:text>
            </ProjectTypeGuids>
          </xsl:when>
          <xsl:otherwise>
          </xsl:otherwise>
        </xsl:choose>
        <OutputType>
          <xsl:choose>
            <xsl:when test="$project/@Type = 'XNA'">
              <xsl:text>Exe</xsl:text>
            </xsl:when>
            <xsl:when test="$project/@Type = 'Console'">
              <xsl:text>Exe</xsl:text>
            </xsl:when>
            <xsl:when test="$project/@Type = 'GUI'">
              <xsl:text>WinExe</xsl:text>
            </xsl:when>
            <xsl:when test="$project/@Type = 'GTK'">
              <xsl:text>WinExe</xsl:text>
            </xsl:when>
            <xsl:when test="$project/@Type = 'App'">
              <xsl:choose>
                <xsl:when test="/Input/Generation/Platform = 'Android'">
                  <xsl:text>Library</xsl:text>
                </xsl:when>
                <xsl:when test="/Input/Generation/Platform = 'WindowsPhone'">
                  <xsl:text>Library</xsl:text>
                </xsl:when>
                <xsl:when test="/Input/Generation/Platform = 'Windows8'">
                  <xsl:text>AppContainerExe</xsl:text>
                </xsl:when>
                <xsl:when test="/Input/Generation/Platform = 'Windows'">
                  <xsl:text>WinExe</xsl:text>
                </xsl:when>
                <xsl:when test="/Input/Generation/Platform = 'iOS'">
                  <xsl:text>Exe</xsl:text>
                </xsl:when>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>Library</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </OutputType>
        <RootNamespace>
          <xsl:value-of select="$project/@Name" />
        </RootNamespace>
        <AssemblyName>
          <xsl:choose>
            <xsl:when test="/Input/Properties/AssemblyName
                      /Platform[@Name=/Input/Generation/Platform]">
              <xsl:value-of select="/Input/Properties/AssemblyName
                                                      /Platform[@Name=/Input/Generation/Platform]
                                                      " />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$project/@Name" />
            </xsl:otherwise>
          </xsl:choose>

        </AssemblyName>
        <AllowUnsafeBlocks>true</AllowUnsafeBlocks>
        <xsl:call-template name="profile_and_version" />
        <xsl:choose>
          <xsl:when test="/Input/Generation/Platform = 'Android'">
            <FileAlignment>512</FileAlignment>
            <AndroidSupportedAbis>armeabi,armeabi-v7a,x86</AndroidSupportedAbis>
            <AndroidStoreUncompressedFileExtensions />
            <MandroidI18n />
           
            <DeployExternal>False</DeployExternal>
            
            <xsl:choose>
              <xsl:when test="$project/@Type = 'App'">
                <xsl:choose>
                  <xsl:when test="Input/Properties/ManifestPrefix">
                    <AndroidManifest>
                      <xsl:value-of select="concat(
                                '..\',
                                $project/@Name,
                                '.',
                                /Input/Generation/Platform,
                                '\Properties\AndroidManifest.xml')"/>
                    </AndroidManifest>
                  </xsl:when>
                  <xsl:otherwise>
                    <AndroidManifest>Properties\AndroidManifest.xml</AndroidManifest>
                  </xsl:otherwise>
                </xsl:choose>
                <AndroidApplication>True</AndroidApplication>
                <AndroidResgenFile>Resources\Resource.designer.cs</AndroidResgenFile>
                <AndroidResgenClass>Resource</AndroidResgenClass>
                <AndroidLinkSkip>System.Core</AndroidLinkSkip><!-- for use with TinyIoC-->
              </xsl:when>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="/Input/Generation/Platform = 'iOS'">
            <SynchReleaseVersion>False</SynchReleaseVersion>
            <xsl:choose>
              <xsl:when test="$project/@Type = 'App'">
                <ConsolePause>false</ConsolePause>
              </xsl:when>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="/Input/Generation/Platform = 'MacOS'">
            <SuppressXamMacUpsell>True</SuppressXamMacUpsell>
          </xsl:when>
          <xsl:when test="/Input/Generation/Platform = 'Ouya'">
            <FileAlignment>512</FileAlignment>
            <AndroidSupportedAbis>armeabi%3barmeabi-v7a%3bx86</AndroidSupportedAbis>
            <AndroidStoreUncompressedFileExtensions />
            <MandroidI18n />
            <xsl:choose>
              <xsl:when test="Input/Properties/ManifestPrefix">
                <AndroidManifest>
                  <xsl:value-of select="concat(
                                '..\',
                                $project/@Name,
                                '.',
                                /Input/Generation/Platform,
                                '\Properties\AndroidManifest.xml')"/>
                </AndroidManifest>
              </xsl:when>
              <xsl:otherwise>
                <AndroidManifest>Properties\AndroidManifest.xml</AndroidManifest>
              </xsl:otherwise>
            </xsl:choose>
            <DeployExternal>False</DeployExternal>
          </xsl:when>
          <xsl:when test="/Input/Generation/Platform = 'WindowsPhone'">
            <xsl:choose>
              <xsl:when test="$project/@Type = 'App'">
                <SilverlightVersion>$(TargetFrameworkVersion)</SilverlightVersion>
                <SilverlightApplication>true</SilverlightApplication>
                <XapFilename>
                  <xsl:value-of select="concat( user:NormalizeXAPName(
                                concat($project/@Name ,'_$(Configuration)','_$(Platform)')),'.xap'
                                )"/>
                </XapFilename>
                <XapOutputs>true</XapOutputs>
                <GenerateSilverlightManifest>true</GenerateSilverlightManifest>
                <xsl:choose>
                  <xsl:when test="Input/Properties/ManifestPrefix">
                    <SilverlightManifestTemplate>
                      <xsl:value-of select="concat(
                                                               '..\',
                                                               $project/@Name,
                                                               '.',
                                                               /Input/Generation/Platform,
                                                               '\Properties\AppManifest.xml')"/>
                    </SilverlightManifestTemplate>
                  </xsl:when>
                  <xsl:otherwise>
                    <SilverlightManifestTemplate>Properties\AppManifest.xml</SilverlightManifestTemplate>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
            </xsl:choose>
          </xsl:when>
        </xsl:choose>
      </PropertyGroup>
      <xsl:choose>
        <xsl:when test="/Input/Generation/Platform = 'iOS'">
          <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Debug|iPhone' ">
            <xsl:call-template name="configuration">
              <xsl:with-param name="project">
                <value-of select="$project" />
              </xsl:with-param>
              <xsl:with-param name="debug">true</xsl:with-param>
            </xsl:call-template>
          </PropertyGroup>
          <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Release|iPhone' ">
            <xsl:call-template name="configuration">
              <xsl:with-param name="project">
                <value-of select="$project" />
              </xsl:with-param>
              <xsl:with-param name="debug">false</xsl:with-param>
            </xsl:call-template>
          </PropertyGroup>
          <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Debug|iPhoneSimulator' ">
            <xsl:call-template name="configuration">
              <xsl:with-param name="project">
                <value-of select="$project" />
              </xsl:with-param>
              <xsl:with-param name="debug">true</xsl:with-param>
            </xsl:call-template>
          </PropertyGroup>
          <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Release|iPhoneSimulator' ">
            <xsl:call-template name="configuration">
              <xsl:with-param name="project">
                <value-of select="$project" />
              </xsl:with-param>
              <xsl:with-param name="debug">false</xsl:with-param>
            </xsl:call-template>
          </PropertyGroup>
          <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Ad-Hoc|iPhone' ">
            <xsl:call-template name="configuration">
              <xsl:with-param name="project">
                <value-of select="$project" />
              </xsl:with-param>
              <xsl:with-param name="debug">false</xsl:with-param>
            </xsl:call-template>
          </PropertyGroup>
          <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'AppStore|iPhone' ">
            <xsl:call-template name="configuration">
              <xsl:with-param name="project">
                <value-of select="$project" />
              </xsl:with-param>
              <xsl:with-param name="debug">false</xsl:with-param>
            </xsl:call-template>
          </PropertyGroup>
        </xsl:when>
        <xsl:when test="/Input/Generation/Platform = 'WindowsPhone'">
          <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Debug|AnyCPU' ">
            <xsl:call-template name="configuration">
              <xsl:with-param name="project">
                <value-of select="$project" />
              </xsl:with-param>
              <xsl:with-param name="debug">true</xsl:with-param>
            </xsl:call-template>
          </PropertyGroup>
          <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Release|AnyCPU' ">
            <xsl:call-template name="configuration">
              <xsl:with-param name="project">
                <value-of select="$project" />
              </xsl:with-param>
              <xsl:with-param name="debug">false</xsl:with-param>
            </xsl:call-template>
          </PropertyGroup>
          <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Debug|x86' ">
            <xsl:call-template name="configuration">
              <xsl:with-param name="project">
                <value-of select="$project" />
              </xsl:with-param>
              <xsl:with-param name="debug">true</xsl:with-param>
            </xsl:call-template>
          </PropertyGroup>
          <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Release|x86' ">
            <xsl:call-template name="configuration">
              <xsl:with-param name="project">
                <value-of select="$project" />
              </xsl:with-param>
              <xsl:with-param name="debug">false</xsl:with-param>
            </xsl:call-template>
          </PropertyGroup>
          <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Debug|ARM' ">
            <xsl:call-template name="configuration">
              <xsl:with-param name="project">
                <value-of select="$project" />
              </xsl:with-param>
              <xsl:with-param name="debug">true</xsl:with-param>
            </xsl:call-template>
          </PropertyGroup>
          <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Release|ARM' ">
            <xsl:call-template name="configuration">
              <xsl:with-param name="project">
                <value-of select="$project" />
              </xsl:with-param>
              <xsl:with-param name="debug">false</xsl:with-param>
            </xsl:call-template>
          </PropertyGroup>
        </xsl:when>
        <xsl:otherwise>
          <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Debug|AnyCPU' ">
            <xsl:call-template name="configuration">
              <xsl:with-param name="project">
                <value-of select="$project" />
              </xsl:with-param>
              <xsl:with-param name="debug">true</xsl:with-param>
            </xsl:call-template>
          </PropertyGroup>
          <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Release|AnyCPU' ">
            <xsl:call-template name="configuration">
              <xsl:with-param name="project">
                <value-of select="$project" />
              </xsl:with-param>
              <xsl:with-param name="debug">false</xsl:with-param>
            </xsl:call-template>
          </PropertyGroup>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="/Input/Properties/ForceArchitecture">
        <PropertyGroup>
          <xsl:attribute name="Condition">
            <xsl:text> '$(Configuration)|$(Platform)' == 'Debug|</xsl:text>
            <xsl:value-of select="/Input/Properties/ForceArchitecture" />
            <xsl:text>' </xsl:text>
          </xsl:attribute>
          <xsl:call-template name="configuration">
            <xsl:with-param name="project">
              <value-of select="$project" />
            </xsl:with-param>
            <xsl:with-param name="debug">true</xsl:with-param>
          </xsl:call-template>
        </PropertyGroup>
        <PropertyGroup>
          <xsl:attribute name="Condition">
            <xsl:text> '$(Configuration)|$(Platform)' == 'Release|</xsl:text>
            <xsl:value-of select="/Input/Properties/ForceArchitecture" />
            <xsl:text>' </xsl:text>
          </xsl:attribute>
          <xsl:call-template name="configuration">
            <xsl:with-param name="project">
              <value-of select="$project" />
            </xsl:with-param>
            <xsl:with-param name="debug">false</xsl:with-param>
          </xsl:call-template>
        </PropertyGroup>
      </xsl:if>

      <xsl:if test="/Input/Generation/UseCSCJVM = 'True'">
        <PropertyGroup>
          <CscToolExe>
            <xsl:text>$(SolutionDir)\Libraries\cscjvm\</xsl:text>
            <xsl:text>cscjvm\bin\Debug\cscjvm.exe</xsl:text>
          </CscToolExe>
        </PropertyGroup>
      </xsl:if>

      <xsl:choose>
        <xsl:when test="$project/@Type = 'Website'">
          <Import>
            <xsl:attribute name="Project">
              <xsl:text>$(MSBuildExtensionsPath)\Microsoft\</xsl:text>
              <xsl:text>VisualStudio\v10.0\WebApplications\</xsl:text>
              <xsl:text>Microsoft.WebApplication.targets</xsl:text>
            </xsl:attribute>
          </Import>
          <Import>
            <xsl:attribute name="Project">
              <xsl:text>..\packages\</xsl:text>
              <xsl:text>RazorGenerator.MsBuild.2.0.1\tools\</xsl:text>
              <xsl:text>RazorGenerator.targets</xsl:text>
            </xsl:attribute>
          </Import>
          <Target Name="BeforeBuild">
            <CallTarget Targets="PrecompileRazorFiles" />
          </Target>
        </xsl:when>
      </xsl:choose>

      <ItemGroup>
        <xsl:if test="$project/@Type = 'GTK'">
          <Reference Include="gtk-sharp, Version=2.4.0.0, Culture=neutral, PublicKeyToken=35e10195dab3c99f">
            <SpecificVersion>False</SpecificVersion>
          </Reference>
          <Reference Include="gdk-sharp, Version=2.4.0.0, Culture=neutral, PublicKeyToken=35e10195dab3c99f">
            <SpecificVersion>False</SpecificVersion>
          </Reference>
          <Reference Include="glib-sharp, Version=2.4.0.0, Culture=neutral, PublicKeyToken=35e10195dab3c99f">
            <SpecificVersion>False</SpecificVersion>
          </Reference>
          <Reference Include="glade-sharp, Version=2.4.0.0, Culture=neutral, PublicKeyToken=35e10195dab3c99f">
            <SpecificVersion>False</SpecificVersion>
          </Reference>
          <Reference Include="pango-sharp, Version=2.4.0.0, Culture=neutral, PublicKeyToken=35e10195dab3c99f">
            <SpecificVersion>False</SpecificVersion>
          </Reference>
          <Reference Include="atk-sharp, Version=2.4.0.0, Culture=neutral, PublicKeyToken=35e10195dab3c99f">
            <SpecificVersion>False</SpecificVersion>
          </Reference>
        </xsl:if>

        <xsl:for-each select="$project/References/Reference">
          <xsl:variable name="include-path" select="./@Include" />
          <xsl:if test="
            count(/Input/Projects/Project[@Name=$include-path]) = 0">
            <xsl:if test="
              count(/Input/Projects/ExternalProject[@Name=$include-path]) = 0">
              <xsl:if test="
                count(/Input/Projects/ContentProject[@Name=$include-path]) = 0">

                <Reference>
                  <xsl:attribute name="Include">
                    <xsl:value-of select="@Include" />
                  </xsl:attribute>
                  <xsl:text />
                </Reference>
              </xsl:if>
            </xsl:if>
          </xsl:if>
        </xsl:for-each>

        <xsl:for-each select="$project/References/Reference">
          <xsl:variable name="include-name" select="./@Include" />
          <xsl:if test="
            count(/Input/Projects/Project[@Name=$include-name]) = 0">
            <xsl:if test="
              count(/Input/Projects/ExternalProject[@Name=$include-name]) > 0">

              <xsl:variable name="extern"
                select="/Input/Projects/ExternalProject[@Name=$include-name]" />

              <xsl:for-each select="$extern/Reference">
                <Reference>
                  <xsl:attribute name="Include">
                    <xsl:value-of select="@Include" />
                  </xsl:attribute>
                </Reference>
              </xsl:for-each>
              <xsl:for-each select="$extern/Platform
                                      [@Type=/Input/Generation/Platform]">
                <xsl:for-each select="./Reference">
                  <Reference>
                    <xsl:attribute name="Include">
                      <xsl:value-of select="@Include" />
                    </xsl:attribute>
                  </Reference>
                </xsl:for-each>
              </xsl:for-each>
            </xsl:if>
          </xsl:if>
        </xsl:for-each>

        <xsl:for-each select="$project/References/Reference">
          <xsl:variable name="include-name" select="./@Include" />
          <xsl:if test="
            count(/Input/Projects/Project[@Name=$include-name]) = 0">
            <xsl:if test="
              count(/Input/Projects/ExternalProject[@Name=$include-name]) > 0">

              <xsl:variable name="extern"
                select="/Input/Projects/ExternalProject[@Name=$include-name]" />

              <xsl:for-each select="$extern/Binary">
                <Reference>
                  <xsl:attribute name="Include">
                    <xsl:value-of select="@Name" />
                  </xsl:attribute>
                  <HintPath>
                    <xsl:value-of
                      select="user:GetRelativePath(
                        concat(
                          $project/@Path,
                          '\',
                          $project/@Name,
                          '.',
                          /Input/Generation/Platform,
                          '.csproj'),
                        @Path)" />
                  </HintPath>
                </Reference>
              </xsl:for-each>
              <xsl:for-each select="$extern/Platform
                                      [@Type=/Input/Generation/Platform]">
                <xsl:for-each select="./Binary">
                  <Reference>
                    <xsl:attribute name="Include">
                      <xsl:value-of select="@Name" />
                    </xsl:attribute>
                    <HintPath>
                      <xsl:value-of
                        select="user:GetRelativePath(
                          concat(
                            $project/@Path,
                            '\',
                            $project/@Name,
                            '.',
                            /Input/Generation/Platform,
                            '.csproj'),
                          @Path)" />
                    </HintPath>
                  </Reference>
                </xsl:for-each>
              </xsl:for-each>
            </xsl:if>
          </xsl:if>
        </xsl:for-each>

        <xsl:for-each select="/Input/NuGet/Package">
          <Reference>
            <xsl:attribute name="Include">
              <xsl:value-of select="@Name" />
            </xsl:attribute>
            <HintPath>
              <xsl:value-of
                select="user:GetRelativePath(
                  concat(
                    $project/@Path,
                    '\',
                    $project/@Name,
                    '.',
                    /Input/Generation/Platform,
                    '.csproj'),
                  .)" />
            </HintPath>
          </Reference>
        </xsl:for-each>
      </ItemGroup>

      <ItemGroup>
        <xsl:for-each select="$project/Files/Compile">
          <xsl:if test="user:ProjectIsActive(
              ./Platforms,
              /Input/Generation/Platform)">
            <xsl:element
              name="{name()}"
              namespace="http://schemas.microsoft.com/developer/msbuild/2003">
              <xsl:attribute name="Include">
                <xsl:value-of select="@Include" />
              </xsl:attribute>
              <xsl:apply-templates select="node()"/>
            </xsl:element>
          </xsl:if>
        </xsl:for-each>
      </ItemGroup>

      <ItemGroup>
        <xsl:for-each select="$project/Files/None">
          <xsl:if test="user:ProjectIsActive(
              ./Platforms,
              /Input/Generation/Platform)">
            <xsl:element
              name="{name()}"
              namespace="http://schemas.microsoft.com/developer/msbuild/2003">
              <xsl:attribute name="Include">
                <xsl:value-of select="@Include" />
              </xsl:attribute>
              <xsl:apply-templates select="node()"/>
            </xsl:element>
          </xsl:if>
        </xsl:for-each>
      </ItemGroup>

      <ItemGroup>
        <xsl:for-each select="$project/Files/Content">
          <xsl:if test="user:ProjectIsActive(
              ./Platforms,
              /Input/Generation/Platform)">
            <xsl:element
              name="{name()}"
              namespace="http://schemas.microsoft.com/developer/msbuild/2003">
              <xsl:attribute name="Include">
                <xsl:value-of select="@Include" />
              </xsl:attribute>
              <xsl:apply-templates select="node()"/>
            </xsl:element>
          </xsl:if>
        </xsl:for-each>
      </ItemGroup>

      <ItemGroup>
        <xsl:for-each select="$project/Files/EmbeddedResource">
          <xsl:if test="user:ProjectIsActive(
              ./Platforms,
              /Input/Generation/Platform)">
            <xsl:element
              name="{name()}"
              namespace="http://schemas.microsoft.com/developer/msbuild/2003">
              <xsl:attribute name="Include">
                <xsl:value-of select="@Include" />
              </xsl:attribute>
              <xsl:apply-templates select="node()"/>
            </xsl:element>
          </xsl:if>
        </xsl:for-each>
      </ItemGroup>

      <ItemGroup>
        <xsl:for-each select="$project/Files/EmbeddedShaderProgram">
          <xsl:if test="user:ProjectIsActive(
              ./Platforms,
              /Input/Generation/Platform)">
            <xsl:element
              name="{name()}"
              namespace="http://schemas.microsoft.com/developer/msbuild/2003">
              <xsl:attribute name="Include">
                <xsl:value-of select="@Include" />
              </xsl:attribute>
              <xsl:apply-templates select="node()"/>
            </xsl:element>
          </xsl:if>
        </xsl:for-each>
      </ItemGroup>

      <ItemGroup>
        <xsl:for-each select="$project/Files/ShaderProgram">
          <xsl:if test="user:ProjectIsActive(
              ./Platforms,
              /Input/Generation/Platform)">
            <xsl:element
              name="{name()}"
              namespace="http://schemas.microsoft.com/developer/msbuild/2003">
              <xsl:attribute name="Include">
                <xsl:value-of select="@Include" />
              </xsl:attribute>
              <xsl:apply-templates select="node()"/>
            </xsl:element>
          </xsl:if>
        </xsl:for-each>
      </ItemGroup>
      <ItemGroup>
        <xsl:for-each select="$project/Files/ApplicationDefinition">
          <xsl:if test="user:ProjectIsActive(
              ./Platforms,
              /Input/Generation/Platform)">
            <xsl:element
              name="{name()}"
              namespace="http://schemas.microsoft.com/developer/msbuild/2003">
              <xsl:attribute name="Include">
                <xsl:value-of select="@Include" />
              </xsl:attribute>
              <Generator>MSBuild:Compile</Generator>
              <SubType>Designer</SubType>
              <xsl:apply-templates select="node()"/>
            </xsl:element>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="$project/Files/Page">
          <xsl:if test="user:ProjectIsActive(
              ./Platforms,
              /Input/Generation/Platform)">
            <xsl:element
              name="{name()}"
              namespace="http://schemas.microsoft.com/developer/msbuild/2003">
              <xsl:attribute name="Include">
                <xsl:value-of select="@Include" />
              </xsl:attribute>
              <Generator>MSBuild:Compile</Generator>
              <SubType>Designer</SubType>
              <xsl:apply-templates select="node()"/>
            </xsl:element>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="$project/Files/AppxManifest">
          <xsl:if test="user:ProjectIsActive(
              ./Platforms,
              /Input/Generation/Platform)">
            <xsl:element
              name="{name()}"
              namespace="http://schemas.microsoft.com/developer/msbuild/2003">
              <xsl:attribute name="Include">
                <xsl:value-of select="@Include" />
              </xsl:attribute>
              <SubType>Designer</SubType>
              <xsl:apply-templates select="node()"/>
            </xsl:element>
          </xsl:if>
        </xsl:for-each>
      </ItemGroup>
      <ItemGroup>
        <xsl:for-each select="$project/Files/BundleResource">
          <xsl:if test="user:ProjectIsActive(
              ./Platforms,
              /Input/Generation/Platform)">
            <xsl:element
              name="{name()}"
              namespace="http://schemas.microsoft.com/developer/msbuild/2003">
              <xsl:attribute name="Include">
                <xsl:value-of select="@Include" />
              </xsl:attribute>
              <xsl:apply-templates select="node()"/>
            </xsl:element>
          </xsl:if>
        </xsl:for-each>
      </ItemGroup>
      <ItemGroup>
        <xsl:for-each select="$project/Files/InterfaceDefinition">
          <xsl:if test="user:ProjectIsActive(
              ./Platforms,
              /Input/Generation/Platform)">
            <xsl:element
              name="{name()}"
              namespace="http://schemas.microsoft.com/developer/msbuild/2003">
              <xsl:attribute name="Include">
                <xsl:value-of select="@Include" />
              </xsl:attribute>
              <xsl:apply-templates select="node()"/>
            </xsl:element>
          </xsl:if>
        </xsl:for-each>
      </ItemGroup>
      <ItemGroup>
        <xsl:for-each select="$project/Files/AndroidResource">
          <xsl:if test="user:ProjectIsActive(
              ./Platforms,
              /Input/Generation/Platform)">
            <xsl:element
              name="{name()}"
              namespace="http://schemas.microsoft.com/developer/msbuild/2003">
              <xsl:attribute name="Include">
                <xsl:value-of select="@Include" />
              </xsl:attribute>
              <xsl:apply-templates select="node()"/>
            </xsl:element>
          </xsl:if>
        </xsl:for-each>
      </ItemGroup>
      <ItemGroup>
        <xsl:for-each select="$project/References/Reference">
          <xsl:variable name="include-path" select="./@Include" />
          <xsl:if test="
            count(/Input/Projects/ContentProject[@Name=$include-path]) > 0">

            <xsl:for-each select="/Input
                                  /Projects
                                  /ContentProject[@Name=$include-path]
                                  /Compiled">
              <xsl:choose>
                <xsl:when test="/Input/Generation/Platform = 'Windows8'">
                  <Content>
                    <xsl:attribute name="Include">
                      <xsl:value-of
                        select="user:GetRelativePath(
                      concat(
                        /Input/Generation/RootPath,
                        $project/@Path,
                        '\',
                        $project/@Name,
                        '.',
                        /Input/Generation/Platform,
                        '.csproj'),
                      current()/FullPath)" />
                    </xsl:attribute>
                    <Link>
                      <xsl:value-of select="current()/RelativePath" />
                    </Link>
                    <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
                  </Content>
                </xsl:when>
                <xsl:when test="/Input/Generation/Platform = 'iOS'">
                  <Content>
                    <xsl:attribute name="Include">
                      <xsl:value-of
                        select="user:GetRelativePath(
                      concat(
                        /Input/Generation/RootPath,
                        $project/@Path,
                        '\',
                        $project/@Name,
                        '.',
                        /Input/Generation/Platform,
                        '.csproj'),
                      current()/FullPath)" />
                    </xsl:attribute>
                    <Link>
                      <xsl:value-of select="current()/RelativePath" />
                    </Link>
                    <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
                  </Content>
                </xsl:when>
                <xsl:when test="/Input/Generation/Platform = 'Android'">
                  <AndroidAsset>
                    <xsl:attribute name="Include">
                      <xsl:value-of
                        select="user:GetRelativePath(
                      concat(
                        /Input/Generation/RootPath,
                        $project/@Path,
                        '\',
                        $project/@Name,
                        '.',
                        /Input/Generation/Platform,
                        '.csproj'),
                      current()/FullPath)" />
                    </xsl:attribute>
                    <Link>
                      <xsl:value-of select="current()/RelativePath" />
                    </Link>
                    <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
                  </AndroidAsset>
                </xsl:when>
                <xsl:otherwise>
                  <None>
                    <xsl:attribute name="Include">
                      <xsl:value-of
                        select="user:GetRelativePath(
                      concat(
                        /Input/Generation/RootPath,
                        $project/@Path,
                        '\',
                        $project/@Name,
                        '.',
                        /Input/Generation/Platform,
                        '.csproj'),
                      current()/FullPath)" />
                    </xsl:attribute>
                    <Link>
                      <xsl:value-of select="current()/RelativePath" />
                    </Link>
                    <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
                  </None>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
          </xsl:if>
        </xsl:for-each>
      </ItemGroup>

      <xsl:choose>
        <xsl:when test="/Input/Generation/Platform = 'Android'">
          <Import Project="$(MSBuildExtensionsPath)\Novell\Novell.MonoDroid.CSharp.targets" />
        </xsl:when>
        <xsl:when test="/Input/Generation/Platform = 'Windows8'">
          <PropertyGroup Condition=" '$(VisualStudioVersion)' == '' or '$(VisualStudioVersion)' &lt; '11.0' ">
            <VisualStudioVersion>11.0</VisualStudioVersion>
          </PropertyGroup>
          <Import Project="$(MSBuildExtensionsPath)\Microsoft\WindowsXaml\v$(VisualStudioVersion)\Microsoft.Windows.UI.Xaml.CSharp.targets" />
        </xsl:when>
        <xsl:when test="/Input/Generation/Platform = 'WindowsPhone'">
          <Import Project="$(MSBuildExtensionsPath)\Microsoft\$(TargetFrameworkIdentifier)\$(TargetFrameworkVersion)\Microsoft.$(TargetFrameworkIdentifier).$(TargetFrameworkVersion).Overrides.targets" />
          <Import Project="$(MSBuildExtensionsPath)\Microsoft\$(TargetFrameworkIdentifier)\$(TargetFrameworkVersion)\Microsoft.$(TargetFrameworkIdentifier).CSharp.targets" />
          <Target Name="MonoGame_RemoveXnaAssemblies" AfterTargets="ImplicitlyExpandTargetFramework">
            <Message Text="MonoGame - Removing XNA Assembly references!" Importance="normal" />
            <ItemGroup>
              <ReferencePath Remove="@(ReferencePath)" Condition="'%(Filename)%(Extension)'=='Microsoft.Xna.Framework.dll'" />
              <ReferencePath Remove="@(ReferencePath)" Condition="'%(Filename)%(Extension)'=='Microsoft.Xna.Framework.GamerServices.dll'" />
              <ReferencePath Remove="@(ReferencePath)" Condition="'%(Filename)%(Extension)'=='Microsoft.Xna.Framework.GamerServicesExtensions.dll'" />
              <ReferencePath Remove="@(ReferencePath)" Condition="'%(Filename)%(Extension)'=='Microsoft.Xna.Framework.Input.Touch.dll'" />
              <ReferencePath Remove="@(ReferencePath)" Condition="'%(Filename)%(Extension)'=='Microsoft.Xna.Framework.MediaLibraryExtensions.dll'" />
            </ItemGroup>
          </Target>
        </xsl:when>
        <xsl:otherwise>
          <Import Project="$(MSBuildBinPath)\Microsoft.CSharp.targets" />
        </xsl:otherwise>
      </xsl:choose>

      <xsl:if test="$project/@Type = 'Tests'">
        <UsingTask
          TaskName="Xunit.Runner.MSBuild.xunit">
          <xsl:attribute name="AssemblyFile">
            <xsl:value-of select="concat(
/Input/Generation/RootPath,
'packages/xunit.runners.1.9.1/tools/xunit.runner.msbuild.dll')" />
          </xsl:attribute>
        </UsingTask>
        <!--

          Disabling the automatic-test-on-build functionality as the MSBuild
          task seems to occasionally crash XBuild when it runs.  We should
          replace the MSBuild task with a task that executes the XUnit runner
          externally and reads in the XML file so that if the XUnit runner
          crashes it won't crash the Mono runtime used for XBuild.

          Change the Condition below to be "$(SkipTestsOnBuild) != 'True'" to
          reenable the test-on-build functionality.

        -->
        <Target Name="AfterBuild" Condition="1 == 0">
          <xunit Assembly="$(TargetPath)" />
        </Target>
      </xsl:if>

      {ADDITIONAL_TRANSFORMS}

      <xsl:if test="$project/NuGet">
        <UsingTask
          TaskName="Protobuild.Tasks.NugetPackTask">
          <xsl:attribute name="AssemblyFile">
            <xsl:value-of select="/Input/Generation/RootPath" />
            <xsl:text>Protobuild.exe</xsl:text>
          </xsl:attribute>
        </UsingTask>

        <Target Name="AfterBuild">
          <NugetPackTask
            ProjectPath="$(ProjectDir)"
            ContinueOnError="WarnAndContinue">
            <xsl:attribute name="NuspecFile">
              <xsl:value-of select="concat(
                $project/@Name,
                '.',
                /Input/Generation/Platform,
                '.nuspec')" />
            </xsl:attribute>
            <xsl:attribute name="RootPath">
              <xsl:value-of select="/Input/Generation/RootPath" />
            </xsl:attribute>
          </NugetPackTask>
        </Target>
      </xsl:if>

      <ItemGroup>
        <xsl:for-each select="$project/References/Reference">
          <xsl:variable name="include-name" select="./@Include" />
          <xsl:if test="
            count(/Input/Projects/Project[@Name=$include-name]) = 0">
            <xsl:if test="
              count(/Input/Projects/ExternalProject[@Name=$include-name]) > 0">

              <xsl:variable name="extern"
                select="/Input/Projects/ExternalProject[@Name=$include-name]" />

              <xsl:for-each select="$extern/Project">
                <ProjectReference>
                  <xsl:attribute name="Include">
                    <xsl:value-of
                      select="user:GetRelativePath(
                        concat(
                          $project/@Path,
                          '\',
                          $project/@Name,
                          '.',
                          /Input/Generation/Platform,
                          '.csproj'),
                        ./@Path)" />
                  </xsl:attribute>
                  <Project>
                    {<xsl:value-of select="./@Guid" />}
                  </Project>
                  <Name>
                    <xsl:value-of select="./@Name" />
                  </Name>
                </ProjectReference>
              </xsl:for-each>
              <xsl:for-each select="$extern/Platform
                                      [@Type=/Input/Generation/Platform]">
                <xsl:for-each select="./Project">
                  <ProjectReference>
                    <xsl:attribute name="Include">
                      <xsl:value-of
                        select="user:GetRelativePath(
                          concat(
                            $project/@Path,
                            '\',
                            $project/@Name,
                            '.',
                            /Input/Generation/Platform,
                            '.csproj'),
                          ./@Path)" />
                    </xsl:attribute>
                    <Project>
                      {<xsl:value-of select="./@Guid" />}
                    </Project>
                    <Name>
                      <xsl:value-of select="./@Name" />
                    </Name>
                  </ProjectReference>
                </xsl:for-each>
              </xsl:for-each>
            </xsl:if>
          </xsl:if>
        </xsl:for-each>

        <xsl:for-each select="$project/References/Reference">
          <xsl:variable name="include-path" select="./@Include" />
          <xsl:if test="
            count(/Input/Projects/Project[@Name=$include-path]) > 0">
            <xsl:if test="
              count(/Input/Projects/ExternalProject[@Name=$include-path]) = 0">

              <xsl:if test="user:ProjectIsActive(
                $project/@Platforms,
                /Input/Generation/Platform)">

                <ProjectReference>
                  <xsl:attribute name="Include">
                    <xsl:value-of
                      select="user:GetRelativePath(
                        concat(
                          $project/@Path,
                          '\',
                          $project/@Name,
                          '.',
                          /Input/Generation/Platform,
                          '.csproj'),
                        concat(
                          /Input/Projects/Project[@Name=$include-path]/@Path,
                          '\',
                          @Include,
                          '.',
                          /Input/Generation/Platform,
                          '.csproj'))" />
                  </xsl:attribute>
                  <Project>
                    {<xsl:value-of
select="/Input/Projects/Project[@Name=$include-path]/@Guid" />}
                  </Project>
                  <Name>
                    <xsl:value-of select="@Include" />
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="/Input/Generation/Platform" />
                  </Name>
                </ProjectReference>
              </xsl:if>
            </xsl:if>
          </xsl:if>
        </xsl:for-each>
      </ItemGroup>

    </Project>

  </xsl:template>

  <xsl:template match="*">
    <xsl:element
      name="{name()}"
      namespace="http://schemas.microsoft.com/developer/msbuild/2003">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>
