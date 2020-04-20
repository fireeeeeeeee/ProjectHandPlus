using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine;
using UnityEditor;

public class CharacterShaderEditor : ShaderGUI
{
    private static class Styles
    {
        public static GUIContent uvSetLabel = new GUIContent("UV Set");

        public static GUIContent albedoText = new GUIContent("Albedo", "Albedo (RGB) and Transparency (A)");      
        public static GUIContent specularMapText = new GUIContent("Specular", "Specular (RGB) and Smoothness (A)");
        public static GUIContent smoothnessText = new GUIContent("Smoothness", "Smoothness value");
        public static GUIContent smoothnessScaleText = new GUIContent("Smoothness", "Smoothness scale factor");       
        public static GUIContent highlightsText = new GUIContent("Specular Highlights", "Specular Highlights");
        public static GUIContent reflectionsText = new GUIContent("Reflections", "Glossy Reflections");
        public static GUIContent normalMapText = new GUIContent("Normal Map", "Normal Map");      
        public static GUIContent occlusionText = new GUIContent("Occlusion", "Occlusion (G)");
        public static GUIContent emissionText = new GUIContent("Color", "Emission (RGB)");      

        public static string primaryMapsText = "Main Maps";
        public static string secondaryMapsText = "Secondary Maps";
        public static string forwardText = "Forward Rendering Options";
        public static string renderingMode = "Rendering Mode";
        public static string advancedText = "Advanced Options";
    }

    MaterialProperty albedoMap = null;
    MaterialProperty albedoColor = null;
    MaterialProperty specularMap = null;
    MaterialProperty specularColor = null;
    MaterialProperty smoothness = null;
    MaterialProperty smoothnessScale = null;
    MaterialProperty highlights = null;
    MaterialProperty reflections = null;
    MaterialProperty bumpScale = null;
    MaterialProperty bumpMap = null;
    MaterialProperty occlusionStrength = null;
    MaterialProperty occlusionMap = null;
    MaterialProperty emissionColorForRendering = null;
    MaterialProperty emissionMap = null;

    MaterialEditor m_MaterialEditor;

    bool m_FirstTimeApply = true;
    ColorPickerHDRConfig m_ColorPickerHDRConfig = new ColorPickerHDRConfig(0f, 99f, 1 / 99f, 3f);

    public void FindProperties(MaterialProperty[] props)
    {
        albedoMap = FindProperty("_MainTex", props);
        albedoColor = FindProperty("_Color", props);
        specularMap = FindProperty("_SpecGlossMap", props, false);
        specularColor = FindProperty("_SpecColor", props, false);
        smoothness = FindProperty("_Glossiness", props);
        smoothnessScale = FindProperty("_GlossMapScale", props, false);
        highlights = FindProperty("_SpecularHighlights", props, false);
        reflections = FindProperty("_GlossyReflections", props, false);
        bumpScale = FindProperty("_BumpScale", props);
        bumpMap = FindProperty("_BumpMap", props);
        occlusionStrength = FindProperty("_OcclusionStrength", props);
        occlusionMap = FindProperty("_OcclusionMap", props);
        emissionColorForRendering = FindProperty("_EmissionColor", props);
        emissionMap = FindProperty("_EmissionMap", props);
    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {
        FindProperties(props); 
        m_MaterialEditor = materialEditor;
        Material material = materialEditor.target as Material;

        if (m_FirstTimeApply)
        {
            MaterialChanged(material);
            m_FirstTimeApply = false;
        }

        ShaderPropertiesGUI(material);
    }

    public void ShaderPropertiesGUI(Material material)
    {
        // Use default labelWidth
        EditorGUIUtility.labelWidth = 0f;

        // Detect any changes to the material
        EditorGUI.BeginChangeCheck();
        {
            BlendModePopup();

            // Primary properties
            GUILayout.Label(Styles.primaryMapsText, EditorStyles.boldLabel);
            DoAlbedoArea(material);
            DoSpecularMetallicArea();
            DoNormalArea();
            m_MaterialEditor.TexturePropertySingleLine(Styles.occlusionText, occlusionMap, occlusionMap.textureValue != null ? occlusionStrength : null);
            DoEmissionArea(material);
            EditorGUI.BeginChangeCheck();
            m_MaterialEditor.TextureScaleOffsetProperty(albedoMap);
            if (EditorGUI.EndChangeCheck())
                emissionMap.textureScaleAndOffset = albedoMap.textureScaleAndOffset; // Apply the main texture scale and offset to the emission texture as well, for Enlighten's sake

            EditorGUILayout.Space();

            // Third properties
            GUILayout.Label(Styles.forwardText, EditorStyles.boldLabel);
            if (highlights != null)
                m_MaterialEditor.ShaderProperty(highlights, Styles.highlightsText);
            if (reflections != null)
                m_MaterialEditor.ShaderProperty(reflections, Styles.reflectionsText);
        }
        if (EditorGUI.EndChangeCheck())
        {

        }

        EditorGUILayout.Space();

        // NB renderqueue editor is not shown on purpose: we want to override it based on blend mode
        GUILayout.Label(Styles.advancedText, EditorStyles.boldLabel);
        m_MaterialEditor.EnableInstancingField();
        m_MaterialEditor.DoubleSidedGIField();
    }

    internal void DetermineWorkflow(MaterialProperty[] props)
    {
    }

    public override void AssignNewShaderToMaterial(Material material, Shader oldShader, Shader newShader)
    {
        // _Emission property is lost after assigning Standard shader to the material
        // thus transfer it before assigning the new shader
        if (material.HasProperty("_Emission"))
        {
            material.SetColor("_EmissionColor", material.GetColor("_Emission"));
        }

        base.AssignNewShaderToMaterial(material, oldShader, newShader);

        if (oldShader == null || !oldShader.name.Contains("Legacy Shaders/"))
        {
            SetupMaterialWithBlendMode(material);
            return;
        }

        DetermineWorkflow(MaterialEditor.GetMaterialProperties(new Material[] { material }));
        MaterialChanged(material);
    }

    void BlendModePopup()
    {
        EditorGUI.BeginChangeCheck();
        if (EditorGUI.EndChangeCheck())
        {
            m_MaterialEditor.RegisterPropertyChangeUndo("Rendering Mode");
        }

        EditorGUI.showMixedValue = false;
    }

    void DoNormalArea()
    {
        m_MaterialEditor.TexturePropertySingleLine(Styles.normalMapText, bumpMap, bumpMap.textureValue != null ? bumpScale : null);

        bumpScale.floatValue = 1;
            
    }

    void DoAlbedoArea(Material material)
    {
        m_MaterialEditor.TexturePropertySingleLine(Styles.albedoText, albedoMap, albedoColor);
    }

    void DoEmissionArea(Material material)
    {
        // Emission for GI?
        if (m_MaterialEditor.EmissionEnabledProperty())
        {
            bool hadEmissionTexture = emissionMap.textureValue != null;

            // Texture and HDR color controls
            m_MaterialEditor.TexturePropertyWithHDRColor(Styles.emissionText, emissionMap, emissionColorForRendering, m_ColorPickerHDRConfig, false);

            // If texture was assigned and color was black set color to white
            float brightness = emissionColorForRendering.colorValue.maxColorComponent;
            if (emissionMap.textureValue != null && !hadEmissionTexture && brightness <= 0f)
                emissionColorForRendering.colorValue = Color.white;

            // change the GI flag and fix it up with emissive as black if necessary
            m_MaterialEditor.LightmapEmissionFlagsProperty(MaterialEditor.kMiniTextureFieldLabelIndentLevel, true);
        }
    }

    void DoSpecularMetallicArea()
    {
        bool hasGlossMap = false;

        hasGlossMap = specularMap.textureValue != null;
        m_MaterialEditor.TexturePropertySingleLine(Styles.specularMapText, specularMap, hasGlossMap ? null : specularColor);

        bool showSmoothnessScale = hasGlossMap;

        int indentation = 2; // align with labels of texture properties
        m_MaterialEditor.ShaderProperty(showSmoothnessScale ? smoothnessScale : smoothness, showSmoothnessScale ? Styles.smoothnessScaleText : Styles.smoothnessText, indentation);

        ++indentation;
    }

    public static void SetupMaterialWithBlendMode(Material material)
    {
        //设置Opaque渲染模式
        material.SetOverrideTag("RenderType", "");
        material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
        material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
        material.SetInt("_ZWrite", 1);
        material.DisableKeyword("_ALPHATEST_ON");
        material.DisableKeyword("_ALPHABLEND_ON");
        material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
        material.renderQueue = -1;
    }

    static void SetMaterialKeywords(Material material)
    {
        // Note: keywords must be based on Material value not on MaterialProperty due to multi-edit & material animation
        // (MaterialProperty value might come from renderer material property block)
        SetKeyword(material, "_NORMALMAP", material.GetTexture("_BumpMap"));
        SetKeyword(material, "_SPECGLOSSMAP", material.GetTexture("_SpecGlossMap"));

        // A material's GI flag internally keeps track of whether emission is enabled at all, it's enabled but has no effect
        // or is enabled and may be modified at runtime. This state depends on the values of the current flag and emissive color.
        // The fixup routine makes sure that the material is in the correct state if/when changes are made to the mode or color.
        MaterialEditor.FixupEmissiveFlag(material);
        bool shouldEmissionBeEnabled = (material.globalIlluminationFlags & MaterialGlobalIlluminationFlags.EmissiveIsBlack) == 0;
        SetKeyword(material, "_EMISSION", shouldEmissionBeEnabled);

    }

    static void MaterialChanged(Material material)
    {
        SetupMaterialWithBlendMode(material);

        SetMaterialKeywords(material);
    }

    static void SetKeyword(Material m, string keyword, bool state)
    {
        if (state)
            m.EnableKeyword(keyword);
        else
            m.DisableKeyword(keyword);
    }
}
