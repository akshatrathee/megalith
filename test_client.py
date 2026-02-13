#!/usr/bin/env python3
"""
LiteLLM Model Mesh - Test Client
Tests routing, escalation, and various model types
"""

import os
from openai import OpenAI
import time

# Configuration
LITELLM_API_KEY = os.getenv("LITELLM_API_KEY", "sk-akshat-homelab-key-change-this")
LITELLM_BASE_URL = os.getenv("LITELLM_BASE_URL", "http://localhost:4000")

client = OpenAI(api_key=LITELLM_API_KEY, base_url=LITELLM_BASE_URL)

def print_section(title):
    print("\n" + "="*60)
    print(f"  {title}")
    print("="*60 + "\n")

def test_model(model_name, prompt, description):
    """Test a single model with timing"""
    print(f"🧪 Testing: {description}")
    print(f"   Model: {model_name}")
    print(f"   Prompt: {prompt[:60]}...")
    
    start = time.time()
    try:
        response = client.chat.completions.create(
            model=model_name,
            messages=[{"role": "user", "content": prompt}],
            max_tokens=100
        )
        duration = time.time() - start
        
        content = response.choices[0].message.content
        print(f"   ✅ Response ({duration:.2f}s): {content[:100]}...")
        print()
        return True
    except Exception as e:
        print(f"   ❌ Error: {str(e)}")
        print()
        return False

def test_escalation():
    """Test user escalation pattern"""
    print_section("USER ESCALATION PATTERN")
    
    prompt = "Explain quantum entanglement in detail"
    
    # Start with fast model
    print("🚀 Step 1: Try fast model first")
    print(f"   Model: fast/general")
    
    start = time.time()
    response = client.chat.completions.create(
        model="fast/general",
        messages=[{"role": "user", "content": prompt}],
        max_tokens=150
    )
    duration = time.time() - start
    
    print(f"   ⏱️  Time: {duration:.2f}s")
    print(f"   📝 Response: {response.choices[0].message.content[:200]}...")
    print()
    
    # Escalate to best
    print("⬆️  Step 2: Escalate to best model")
    print(f"   Model: cloud/claude-opus")
    
    start = time.time()
    response = client.chat.completions.create(
        model="cloud/claude-opus",
        messages=[{"role": "user", "content": prompt}],
        max_tokens=150
    )
    duration = time.time() - start
    
    print(f"   ⏱️  Time: {duration:.2f}s")
    print(f"   📝 Response: {response.choices[0].message.content[:200]}...")
    print()

def test_embeddings():
    """Test embedding models"""
    print_section("EMBEDDINGS")
    
    texts = [
        "The quick brown fox jumps over the lazy dog",
        "Machine learning is a subset of artificial intelligence"
    ]
    
    for model in ["embeddings/fast", "embeddings/large"]:
        print(f"📊 Testing: {model}")
        try:
            response = client.embeddings.create(
                model=model,
                input=texts
            )
            dim = len(response.data[0].embedding)
            print(f"   ✅ Dimension: {dim}")
            print(f"   📦 Embeddings: {len(response.data)} vectors")
            print()
        except Exception as e:
            print(f"   ❌ Error: {str(e)}")
            print()

def main():
    print("""
    ╔══════════════════════════════════════════════════════════╗
    ║   LiteLLM Model Mesh - Test Suite                       ║
    ╚══════════════════════════════════════════════════════════╝
    """)
    
    print(f"🌐 Base URL: {LITELLM_BASE_URL}")
    print(f"🔑 API Key: {LITELLM_API_KEY[:20]}...")
    
    # Test 1: Basic Routing
    print_section("AUTOMATIC ROUTING TESTS")
    
    tests = [
        ("gpt-3.5-turbo", "Hello! How are you?", "Simple chat (auto-routes to fast)"),
        ("code", "Write a quicksort in Python", "Code generation"),
        ("vision", "Describe what you see", "Vision task (requires image)"),
        ("fast", "What is 2+2?", "Ultra-fast query"),
        ("balanced", "Explain neural networks", "Balanced quality/speed"),
    ]
    
    results = []
    for model, prompt, desc in tests:
        success = test_model(model, prompt, desc)
        results.append((desc, success))
    
    # Test 2: Specific Models
    print_section("SPECIFIC MODEL TESTS")
    
    specific_tests = [
        ("ultrafast/chat", "Hi there!", "Ultra-fast local"),
        ("heavy/code", "Implement binary search in Rust", "Heavy code model"),
        ("cloud/claude-sonnet", "Explain relativity", "Cloud Claude"),
        ("cloud/gpt-4o-mini", "Quick question", "Cloud GPT fast"),
    ]
    
    for model, prompt, desc in specific_tests:
        success = test_model(model, prompt, desc)
        results.append((desc, success))
    
    # Test 3: Escalation Pattern
    try:
        test_escalation()
    except Exception as e:
        print(f"❌ Escalation test failed: {e}")
    
    # Test 4: Embeddings
    try:
        test_embeddings()
    except Exception as e:
        print(f"❌ Embedding test failed: {e}")
    
    # Summary
    print_section("TEST SUMMARY")
    
    passed = sum(1 for _, success in results if success)
    total = len(results)
    
    print(f"✅ Passed: {passed}/{total}")
    print(f"❌ Failed: {total - passed}/{total}")
    print()
    
    if passed == total:
        print("🎉 All tests passed! Your model mesh is working perfectly.")
    else:
        print("⚠️  Some tests failed. Check the logs above for details.")
    
    print()
    print("💡 Tips:")
    print("   - Use 'gpt-3.5-turbo' for fast local routing")
    print("   - Use 'best' for highest quality (cloud)")
    print("   - Use 'code' for code generation")
    print("   - Use 'research' for web-connected queries")
    print()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⏹️  Test interrupted by user")
    except Exception as e:
        print(f"\n\n❌ Fatal error: {e}")
        import traceback
        traceback.print_exc()
