/*!@file GUI/SDLdisplayStream.H A FrameOstream class that sends images to SDL windows */

// //////////////////////////////////////////////////////////////////// //
// The iLab Neuromorphic Vision C++ Toolkit - Copyright (C) 2000-2005   //
// by the University of Southern California (USC) and the iLab at USC.  //
// See http://iLab.usc.edu for information about this project.          //
// //////////////////////////////////////////////////////////////////// //
// Major portions of the iLab Neuromorphic Vision Toolkit are protected //
// under the U.S. patent ``Computation of Intrinsic Perceptual Saliency //
// in Visual Environments, and Applications'' by Christof Koch and      //
// Laurent Itti, California Institute of Technology, 2001 (patent       //
// pending; application number 09/912,225 filed July 23, 2001; see      //
// http://pair.uspto.gov/cgi-bin/final/home.pl for current status).     //
// //////////////////////////////////////////////////////////////////// //
// This file is part of the iLab Neuromorphic Vision C++ Toolkit.       //
//                                                                      //
// The iLab Neuromorphic Vision C++ Toolkit is free software; you can   //
// redistribute it and/or modify it under the terms of the GNU General  //
// Public License as published by the Free Software Foundation; either  //
// version 2 of the License, or (at your option) any later version.     //
//                                                                      //
// The iLab Neuromorphic Vision C++ Toolkit is distributed in the hope  //
// that it will be useful, but WITHOUT ANY WARRANTY; without even the   //
// implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU General Public License for more details.       //
//                                                                      //
// You should have received a copy of the GNU General Public License    //
// along with the iLab Neuromorphic Vision C++ Toolkit; if not, write   //
// to the Free Software Foundation, Inc., 59 Temple Place, Suite 330,   //
// Boston, MA 02111-1307 USA.                                           //
// //////////////////////////////////////////////////////////////////// //
//
// Primary maintainer for this file: Rob Peters <rjpeters at usc dot edu>
// $HeadURL: svn://isvn.usc.edu/software/invt/trunk/saliency/src/GUI/SDLdisplayStream.H $
// $Id: SDLdisplayStream.H 8069 2007-03-08 05:01:16Z rjpeters $
//

#ifndef GUI_SDLDISPLAYSTREAM_H_DEFINED
#define GUI_SDLDISPLAYSTREAM_H_DEFINED

#ifdef HAVE_SDL_SDL_H

#include "Component/ModelParam.H"
#include "Transport/FrameOstream.H"

//! A FrameOstream class that sends images to SDL windows
class SDLdisplayStream : public FrameOstream
{
public:
  //! Constructor
  SDLdisplayStream(OptionManager& mgr);

  //! Virtual destructor.
  virtual ~SDLdisplayStream();

  //! Write a frame to the named onscreen window
  /*! If no such window yet exists, it will be created on the fly. */
  virtual void writeFrame(const GenericFrame& image,
                          const std::string& shortname,
                          const FrameInfo& auxinfo = FrameOstream::defaultInfo);

  //! Returns true if the user has clicked a close button on any open window
  virtual bool isVoid() const;

  //! Close the SDL window, regardless of the value of shortname
  virtual void closeStream(const std::string& shortname);

private:
  virtual void start1();

  OModelParam<bool> itsTestMode;

  struct WindowMap;
  WindowMap* wmap;
};

#endif // HAVE_SDL_SDL_H

// ######################################################################
/* So things look consistent in everyone's emacs... */
/* Local Variables: */
/* mode: c++ */
/* indent-tabs-mode: nil */
/* End: */

#endif // GUI_SDLDISPLAYSTREAM_H_DEFINED
