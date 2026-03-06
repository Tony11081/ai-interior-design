import Link from 'next/link'
import { ArrowRight, Upload, Palette, Sparkles } from 'lucide-react'

export default function HomePage() {
  return (
    <div className="min-h-screen bg-white">
      {/* Header */}
      <header className="border-b border-gray-200">
        <div className="container mx-auto px-4 py-4 flex items-center justify-between">
          <div className="text-2xl font-bold text-gray-900">AI Interior Design</div>
          <nav className="hidden md:flex items-center gap-8">
            <Link href="/pricing" className="text-gray-600 hover:text-gray-900">Pricing</Link>
            <Link href="/examples" className="text-gray-600 hover:text-gray-900">Examples</Link>
            <Link href="/login" className="text-gray-600 hover:text-gray-900">Sign In</Link>
            <Link 
              href="/signup" 
              className="px-6 py-2 bg-gray-900 text-white rounded-full hover:bg-gray-800"
            >
              Get Started
            </Link>
          </nav>
        </div>
      </header>

      {/* Hero Section */}
      <section className="container mx-auto px-4 py-20">
        <div className="grid md:grid-cols-2 gap-12 items-center">
          {/* Left: Floor Plan */}
          <div className="bg-gray-50 rounded-3xl p-8 aspect-square flex items-center justify-center">
            <div className="text-center">
              <div className="text-6xl mb-4">📐</div>
              <div className="text-gray-600">Floor Plan</div>
            </div>
          </div>

          {/* Right: 3D Render */}
          <div className="bg-gray-900 rounded-3xl p-8 aspect-square flex items-center justify-center">
            <div className="text-center">
              <div className="text-6xl mb-4">🏠</div>
              <div className="text-white">3D Design</div>
            </div>
          </div>
        </div>

        <div className="text-center mt-12">
          <h1 className="text-5xl md:text-6xl font-bold text-gray-900 mb-6">
            Transform Floor Plans into<br />Stunning 3D Designs
          </h1>
          <p className="text-xl text-gray-600 mb-8">
            AI-powered interior design in minutes
          </p>
          <Link 
            href="/projects/new"
            className="inline-flex items-center gap-2 px-8 py-4 bg-gray-900 text-white rounded-full text-lg hover:bg-gray-800"
          >
            Start Your Project
            <ArrowRight className="w-5 h-5" />
          </Link>
        </div>
      </section>

      {/* How It Works */}
      <section className="bg-gray-50 py-20">
        <div className="container mx-auto px-4">
          <h2 className="text-4xl font-bold text-center mb-16">How It Works</h2>
          <div className="grid md:grid-cols-3 gap-8">
            <div className="bg-white rounded-2xl p-8 text-center">
              <div className="w-16 h-16 bg-gray-900 rounded-full flex items-center justify-center mx-auto mb-6">
                <Upload className="w-8 h-8 text-white" />
              </div>
              <h3 className="text-xl font-bold mb-4">Upload Floor Plan</h3>
              <p className="text-gray-600">
                Upload your floor plan image or PDF. Our AI will recognize rooms and dimensions.
              </p>
            </div>

            <div className="bg-white rounded-2xl p-8 text-center">
              <div className="w-16 h-16 bg-gray-900 rounded-full flex items-center justify-center mx-auto mb-6">
                <Palette className="w-8 h-8 text-white" />
              </div>
              <h3 className="text-xl font-bold mb-4">Choose Your Style</h3>
              <p className="text-gray-600">
                Select from Modern, Industrial, Scandinavian and more design styles.
              </p>
            </div>

            <div className="bg-white rounded-2xl p-8 text-center">
              <div className="w-16 h-16 bg-gray-900 rounded-full flex items-center justify-center mx-auto mb-6">
                <Sparkles className="w-8 h-8 text-white" />
              </div>
              <h3 className="text-xl font-bold mb-4">Get Professional Results</h3>
              <p className="text-gray-600">
                Receive photorealistic 3D renders, floor plans, and shopping lists.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Pricing Preview */}
      <section className="container mx-auto px-4 py-20">
        <h2 className="text-4xl font-bold text-center mb-16">Simple Pricing</h2>
        <div className="grid md:grid-cols-3 gap-8 max-w-5xl mx-auto">
          {/* Free */}
          <div className="border-2 border-gray-200 rounded-2xl p-8">
            <div className="text-sm font-semibold text-gray-600 mb-2">FREE</div>
            <div className="text-4xl font-bold mb-6">$0</div>
            <ul className="space-y-3 mb-8">
              <li className="text-gray-600">✓ 1 project</li>
              <li className="text-gray-600">✓ 1 design version</li>
              <li className="text-gray-600">✓ Low-res renders</li>
            </ul>
            <Link 
              href="/signup"
              className="block w-full py-3 text-center border-2 border-gray-900 text-gray-900 rounded-full hover:bg-gray-50"
            >
              Get Started
            </Link>
          </div>

          {/* Pro */}
          <div className="border-2 border-gray-900 rounded-2xl p-8 relative">
            <div className="absolute -top-4 left-1/2 -translate-x-1/2 bg-gray-900 text-white px-4 py-1 rounded-full text-sm">
              Most Popular
            </div>
            <div className="text-sm font-semibold text-gray-600 mb-2">PRO</div>
            <div className="text-4xl font-bold mb-6">$29<span className="text-lg text-gray-600">/mo</span></div>
            <ul className="space-y-3 mb-8">
              <li className="text-gray-600">✓ 5 projects</li>
              <li className="text-gray-600">✓ 3 design versions</li>
              <li className="text-gray-600">✓ High-res renders</li>
              <li className="text-gray-600">✓ PDF exports</li>
            </ul>
            <Link 
              href="/signup?plan=pro"
              className="block w-full py-3 text-center bg-gray-900 text-white rounded-full hover:bg-gray-800"
            >
              Start Free Trial
            </Link>
          </div>

          {/* Studio */}
          <div className="border-2 border-gray-200 rounded-2xl p-8">
            <div className="text-sm font-semibold text-gray-600 mb-2">STUDIO</div>
            <div className="text-4xl font-bold mb-6">$79<span className="text-lg text-gray-600">/mo</span></div>
            <ul className="space-y-3 mb-8">
              <li className="text-gray-600">✓ 20 projects</li>
              <li className="text-gray-600">✓ 5 design versions</li>
              <li className="text-gray-600">✓ 4K renders</li>
              <li className="text-gray-600">✓ Team collaboration</li>
            </ul>
            <Link 
              href="/signup?plan=studio"
              className="block w-full py-3 text-center border-2 border-gray-900 text-gray-900 rounded-full hover:bg-gray-50"
            >
              Start Free Trial
            </Link>
          </div>
        </div>
        <div className="text-center mt-8">
          <Link href="/pricing" className="text-gray-600 hover:text-gray-900">
            View full pricing details →
          </Link>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t border-gray-200 py-12">
        <div className="container mx-auto px-4">
          <div className="grid md:grid-cols-4 gap-8">
            <div>
              <div className="font-bold text-lg mb-4">AI Interior Design</div>
              <p className="text-gray-600 text-sm">
                Transform your space with AI-powered design
              </p>
            </div>
            <div>
              <div className="font-semibold mb-4">Product</div>
              <ul className="space-y-2 text-sm text-gray-600">
                <li><Link href="/features">Features</Link></li>
                <li><Link href="/pricing">Pricing</Link></li>
                <li><Link href="/examples">Examples</Link></li>
              </ul>
            </div>
            <div>
              <div className="font-semibold mb-4">Company</div>
              <ul className="space-y-2 text-sm text-gray-600">
                <li><Link href="/about">About</Link></li>
                <li><Link href="/contact">Contact</Link></li>
                <li><Link href="/blog">Blog</Link></li>
              </ul>
            </div>
            <div>
              <div className="font-semibold mb-4">Legal</div>
              <ul className="space-y-2 text-sm text-gray-600">
                <li><Link href="/privacy">Privacy</Link></li>
                <li><Link href="/terms">Terms</Link></li>
              </ul>
            </div>
          </div>
          <div className="mt-12 pt-8 border-t border-gray-200 text-center text-sm text-gray-600">
            © 2026 AI Interior Design. All rights reserved.
          </div>
        </div>
      </footer>
    </div>
  )
}
